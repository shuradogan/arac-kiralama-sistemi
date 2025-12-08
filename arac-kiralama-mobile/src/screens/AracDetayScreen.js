
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  ActivityIndicator,
  Alert,
} from 'react-native';
import axios from 'axios';

export default function AracDetayScreen({ route, navigation }) {
  const { aracID } = route.params;
  const [arac, setArac] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadAracDetay();
  }, []);

  const loadAracDetay = async () => {
    try {
      const response = await axios.get(`http://192.168.1.101:3000/api/araclar/${aracID}`);
      
      if (response.data.success) {
        setArac(response.data.data);
      }
    } catch (error) {
      Alert.alert('Hata', 'Araç detayı yüklenemedi!');
      navigation.goBack();
    } finally {
      setLoading(false);
    }
  };

  const handleKirala = () => {
    navigation.navigate('KiralamaForm', { arac });
  };

  if (loading) {
    return (
      <View style={styles.centerContainer}>
        <ActivityIndicator size="large" color="#007AFF" />
      </View>
    );
  }

  if (!arac) {
    return (
      <View style={styles.centerContainer}>
        <Text>Araç bulunamadı</Text>
      </View>
    );
  }

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>
          {arac.markaAdi} {arac.modelAdi}
        </Text>
        <Text style={styles.price}>₺{arac.gunlukKiraUcreti}/gün</Text>
      </View>

      <View style={styles.card}>
        <Text style={styles.sectionTitle}>Araç Bilgileri</Text>
        
        <View style={styles.infoRow}>
          <Text style={styles.infoLabel}> Plaka:</Text>
          <Text style={styles.infoValue}>{arac.plaka}</Text>
        </View>

        <View style={styles.infoRow}>
          <Text style={styles.infoLabel}> Yıl:</Text>
          <Text style={styles.infoValue}>{arac.yil}</Text>
        </View>

        <View style={styles.infoRow}>
          <Text style={styles.infoLabel}> Renk:</Text>
          <Text style={styles.infoValue}>{arac.renk}</Text>
        </View>

        <View style={styles.infoRow}>
          <Text style={styles.infoLabel}> Vites:</Text>
          <Text style={styles.infoValue}>{arac.vitesTipi}</Text>
        </View>

        <View style={styles.infoRow}>
          <Text style={styles.infoLabel}> Yakıt:</Text>
          <Text style={styles.infoValue}>{arac.yakitTipi}</Text>
        </View>

        <View style={styles.infoRow}>
          <Text style={styles.infoLabel}> Koltuk:</Text>
          <Text style={styles.infoValue}>{arac.koltukSayisi} Kişilik</Text>
        </View>

        <View style={styles.infoRow}>
          <Text style={styles.infoLabel}> Kategori:</Text>
          <Text style={styles.infoValue}>{arac.kategoriAdi}</Text>
        </View>

        <View style={styles.infoRow}>
          <Text style={styles.infoLabel}> Durum:</Text>
          <View style={[styles.badge, styles.badgeSuccess]}>
            <Text style={styles.badgeText}>{arac.durum}</Text>
          </View>
        </View>
      </View>

      <TouchableOpacity
        style={styles.button}
        onPress={handleKirala}
        disabled={arac.durum !== 'Musait'}
      >
        <Text style={styles.buttonText}>
          {arac.durum === 'Musait' ? 'Kirala' : 'Müsait Değil'}
        </Text>
      </TouchableOpacity>
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
    padding: 20,
    alignItems: 'center',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 10,
  },
  price: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#fff',
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
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 15,
    color: '#333',
  },
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 10,
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
  badge: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 15,
  },
  badgeSuccess: {
    backgroundColor: '#4CAF50',
  },
  badgeText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: 'bold',
  },
  button: {
    backgroundColor: '#007AFF',
    margin: 15,
    padding: 18,
    borderRadius: 12,
    alignItems: 'center',
  },
  buttonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
});
