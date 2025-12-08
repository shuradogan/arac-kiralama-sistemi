
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  ActivityIndicator,
  Alert,
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';

export default function ProfilScreen({ navigation }) {
  const [profil, setProfil] = useState(null);
  const [loading, setLoading] = useState(true);
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);
  
  const [formData, setFormData] = useState({
    ad: '',
    soyad: '',
    telefon: '',
    dogumTarihi: '',
    cinsiyet: 'Erkek',
  });

  useEffect(() => {
    loadProfil();
  }, []);

  const loadProfil = async () => {
    try {
      const token = await AsyncStorage.getItem('userToken');
      // IP adresinizi buraya yazın!
      const response = await axios.get('http://192.168.1.101:3000/api/profil', {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      if (response.data.success) {
        const data = response.data.data;
        setProfil(data);
        setFormData({
          ad: data.ad,
          soyad: data.soyad,
          telefon: data.telefon,
          dogumTarihi: data.dogumTarihi ? data.dogumTarihi.split('T')[0] : '',
          cinsiyet: data.cinsiyet || 'Erkek',
        });
      }
    } catch (error) {
      Alert.alert('Hata', 'Profil yüklenemedi!');
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    if (!formData.ad || !formData.soyad || !formData.telefon) {
      Alert.alert('Hata', 'Ad, soyad ve telefon gerekli!');
      return;
    }

    setSaving(true);
    try {
      const token = await AsyncStorage.getItem('userToken');
      const response = await axios.put(
        'http://192.168.1.45:3000/api/profil',
        formData,
        { headers: { Authorization: `Bearer ${token}` } }
      );

      if (response.data.success) {
        Alert.alert('Başarılı', 'Profil güncellendi!');
        setEditing(false);
        loadProfil();
      }
    } catch (error) {
      Alert.alert('Hata', error.response?.data?.message || 'Profil güncellenemedi!');
    } finally {
      setSaving(false);
    }
  };

  const handleLogout = async () => {
    Alert.alert(
      'Çıkış',
      'Çıkış yapmak istediğinizden emin misiniz?',
      [
        { text: 'İptal', style: 'cancel' },
        { 
          text: 'Çıkış Yap', 
          style: 'destructive',
          onPress: async () => {
            await AsyncStorage.removeItem('userToken');
            await AsyncStorage.removeItem('userData');
            navigation.replace('Login');
          }
        }
      ]
    );
  };

  if (loading) {
    return (
      <View style={styles.centerContainer}>
        <ActivityIndicator size="large" color="#007AFF" />
      </View>
    );
  }

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <View style={styles.avatarContainer}>
          <Text style={styles.avatar}>
            {profil?.ad?.[0]}{profil?.soyad?.[0]}
          </Text>
        </View>
        <Text style={styles.headerName}>
          {profil?.ad} {profil?.soyad}
        </Text>
        <Text style={styles.headerEmail}>{profil?.email}</Text>
      </View>

      <View style={styles.card}>
        <View style={styles.cardHeader}>
          <Text style={styles.cardTitle}>Kişisel Bilgiler</Text>
          <TouchableOpacity onPress={() => setEditing(!editing)}>
            <Text style={styles.editButton}>{editing ? 'İptal' : 'Düzenle'}</Text>
          </TouchableOpacity>
        </View>

        {editing ? (
          <>
            <TextInput
              style={styles.input}
              placeholder="Ad"
              value={formData.ad}
              onChangeText={(text) => setFormData({ ...formData, ad: text })}
            />

            <TextInput
              style={styles.input}
              placeholder="Soyad"
              value={formData.soyad}
              onChangeText={(text) => setFormData({ ...formData, soyad: text })}
            />

            <TextInput
              style={styles.input}
              placeholder="Telefon"
              value={formData.telefon}
              onChangeText={(text) => setFormData({ ...formData, telefon: text })}
              keyboardType="phone-pad"
            />

            <TextInput
              style={styles.input}
              placeholder="Doğum Tarihi (YYYY-MM-DD)"
              value={formData.dogumTarihi}
              onChangeText={(text) => setFormData({ ...formData, dogumTarihi: text })}
            />

            <View style={styles.genderContainer}>
              <TouchableOpacity
                style={[
                  styles.genderButton,
                  formData.cinsiyet === 'Erkek' && styles.genderButtonActive
                ]}
                onPress={() => setFormData({ ...formData, cinsiyet: 'Erkek' })}
              >
                <Text style={[
                  styles.genderText,
                  formData.cinsiyet === 'Erkek' && styles.genderTextActive
                ]}>Erkek</Text>
              </TouchableOpacity>

              <TouchableOpacity
                style={[
                  styles.genderButton,
                  formData.cinsiyet === 'Kadın' && styles.genderButtonActive
                ]}
                onPress={() => setFormData({ ...formData, cinsiyet: 'Kadın' })}
              >
                <Text style={[
                  styles.genderText,
                  formData.cinsiyet === 'Kadın' && styles.genderTextActive
                ]}>Kadın</Text>
              </TouchableOpacity>
            </View>

            <TouchableOpacity
              style={[styles.button, saving && styles.buttonDisabled]}
              onPress={handleSave}
              disabled={saving}
            >
              {saving ? (
                <ActivityIndicator color="#fff" />
              ) : (
                <Text style={styles.buttonText}>Kaydet</Text>
              )}
            </TouchableOpacity>
          </>
        ) : (
          <>
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Ad:</Text>
              <Text style={styles.infoValue}>{profil?.ad}</Text>
            </View>

            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Soyad:</Text>
              <Text style={styles.infoValue}>{profil?.soyad}</Text>
            </View>

            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>TC No:</Text>
              <Text style={styles.infoValue}>{profil?.tcNo}</Text>
            </View>

            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Email:</Text>
              <Text style={styles.infoValue}>{profil?.email}</Text>
            </View>

            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Telefon:</Text>
              <Text style={styles.infoValue}>{profil?.telefon}</Text>
            </View>

            {profil?.dogumTarihi && (
              <View style={styles.infoRow}>
                <Text style={styles.infoLabel}>Doğum Tarihi:</Text>
                <Text style={styles.infoValue}>
                  {new Date(profil.dogumTarihi).toLocaleDateString('tr-TR')}
                </Text>
              </View>
            )}

            {profil?.cinsiyet && (
              <View style={styles.infoRow}>
                <Text style={styles.infoLabel}>Cinsiyet:</Text>
                <Text style={styles.infoValue}>{profil.cinsiyet}</Text>
              </View>
            )}
          </>
        )}
      </View>

      <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
        <Text style={styles.logoutButtonText}>Çıkış Yap</Text>
      </TouchableOpacity>

      <View style={{ height: 30 }} />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  centerContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  header: {
    backgroundColor: '#007AFF',
    padding: 30,
    alignItems: 'center',
  },
  avatarContainer: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: '#fff',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 15,
  },
  avatar: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#007AFF',
  },
  headerName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 5,
  },
  headerEmail: {
    fontSize: 14,
    color: '#fff',
    opacity: 0.9,
  },
  card: {
    backgroundColor: '#fff',
    margin: 15,
    padding: 20,
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  editButton: {
    fontSize: 16,
    color: '#007AFF',
    fontWeight: '600',
  },
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  infoLabel: {
    fontSize: 16,
    color: '#666',
  },
  infoValue: {
    fontSize: 16,
    fontWeight: '500',
    color: '#333',
  },
  input: {
    backgroundColor: '#f8f8f8',
    padding: 15,
    borderRadius: 10,
    marginBottom: 15,
    fontSize: 16,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  genderContainer: {
    flexDirection: 'row',
    marginBottom: 15,
    gap: 10,
  },
  genderButton: {
    flex: 1,
    padding: 15,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#ddd',
    backgroundColor: '#f8f8f8',
    alignItems: 'center',
  },
  genderButtonActive: {
    backgroundColor: '#007AFF',
    borderColor: '#007AFF',
  },
  genderText: {
    fontSize: 16,
    color: '#666',
  },
  genderTextActive: {
    color: '#fff',
    fontWeight: 'bold',
  },
  button: {
    backgroundColor: '#007AFF',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
    marginTop: 10,
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  buttonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  logoutButton: {
    backgroundColor: '#FF3B30',
    margin: 15,
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
  },
  logoutButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
});
