
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
  ActivityIndicator,
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';

export default function KiralamaFormScreen({ route, navigation }) {
  const { arac } = route.params;
  const [lokasyonlar, setLokasyonlar] = useState([]);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  
  const [formData, setFormData] = useState({
    teslimLokasyonID: null,
    iadeLokasyonID: null,
    baslangicTarihi: new Date().toISOString().split('T')[0],
    bitisTarihi: new Date(Date.now() + 86400000).toISOString().split('T')[0], // +1 gün
  });

  useEffect(() => {
    loadLokasyonlar();
  }, []);

  const loadLokasyonlar = async () => {
    try {
      const token = await AsyncStorage.getItem('userToken');
      // IP adresinizi buraya yazın!
      const response = await axios.get('http://192.168.1.101:3000/api/kiralamalar/lokasyonlar', {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      if (response.data.success) {
        setLokasyonlar(response.data.data);
        if (response.data.data.length > 0) {
          setFormData({
            ...formData,
            teslimLokasyonID: response.data.data[0].lokasyonID,
            iadeLokasyonID: response.data.data[0].lokasyonID,
          });
        }
      }
    } catch (error) {
      Alert.alert('Hata', 'Lokasyonlar yüklenemedi!');
    } finally {
      setLoading(false);
    }
  };

  const calculatePrice = () => {
    const start = new Date(formData.baslangicTarihi);
    const end = new Date(formData.bitisTarihi);
    const days = Math.ceil((end - start) / (1000 * 60 * 60 * 24));
    
    if (days < 1) return 0;
    
    return days * parseFloat(arac.gunlukKiraUcreti);
  };

  const handleSubmit = async () => {
    if (!formData.teslimLokasyonID || !formData.iadeLokasyonID) {
      Alert.alert('Hata', 'Lütfen lokasyonları seçin!');
      return;
    }

    const gunSayisi = Math.ceil(
      (new Date(formData.bitisTarihi) - new Date(formData.baslangicTarihi)) / (1000 * 60 * 60 * 24)
    );

    if (gunSayisi < 1) {
      Alert.alert('Hata', 'İade tarihi başlangıç tarihinden sonra olmalıdır!');
      return;
    }

    Alert.alert(
      'Kiralama Onayı',
      `${arac.markaAdi} ${arac.modelAdi}\n${gunSayisi} gün\nToplam: ₺${calculatePrice()}\n\nOnaylıyor musunuz?`,
      [
        { text: 'İptal', style: 'cancel' },
        { text: 'Onayla', onPress: submitKiralama }
      ]
    );
  };

  const submitKiralama = async () => {
    setSubmitting(true);
    try {
      const token = await AsyncStorage.getItem('userToken');
      
      const kiralamaData = {
        aracID: arac.aracID,
        teslimLokasyonID: formData.teslimLokasyonID,
        iadeLokasyonID: formData.iadeLokasyonID,
        baslangicTarihi: formData.baslangicTarihi + ' 10:00:00',
        bitisTarihi: formData.bitisTarihi + ' 10:00:00',
      };

      const response = await axios.post(
        'http://192.168.1.101:3000/api/kiralamalar',
        kiralamaData,
        { headers: { Authorization: `Bearer ${token}` } }
      );

      if (response.data.success) {
        Alert.alert(
          'Başarılı!',
          'Kiralama başarıyla oluşturuldu!',
          [
            { 
              text: 'Tamam', 
              onPress: () => navigation.navigate('Kiralamalarım')
            }
          ]
        );
      }
    } catch (error) {
      Alert.alert('Hata', error.response?.data?.message || 'Kiralama oluşturulamadı!');
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <View style={styles.centerContainer}>
        <ActivityIndicator size="large" color="#007AFF" />
      </View>
    );
  }

  const toplamTutar = calculatePrice();
  const gunSayisi = Math.ceil(
    (new Date(formData.bitisTarihi) - new Date(formData.baslangicTarihi)) / (1000 * 60 * 60 * 24)
  );

  return (
    <ScrollView style={styles.container}>
      <View style={styles.aracCard}>
        <Text style={styles.aracTitle}>
          {arac.markaAdi} {arac.modelAdi}
        </Text>
        <Text style={styles.aracDetail}>
          {arac.yil} • {arac.renk} • {arac.plaka}
        </Text>
        <Text style={styles.aracPrice}>₺{arac.gunlukKiraUcreti}/gün</Text>
      </View>

      <View style={styles.card}>
        <Text style={styles.sectionTitle}>Teslim Lokasyonu</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
          {lokasyonlar.map((lok) => (
            <TouchableOpacity
              key={lok.lokasyonID}
              style={[
                styles.lokasyonButton,
                formData.teslimLokasyonID === lok.lokasyonID && styles.lokasyonButtonActive
              ]}
              onPress={() => setFormData({ ...formData, teslimLokasyonID: lok.lokasyonID })}
            >
              <Text style={[
                styles.lokasyonText,
                formData.teslimLokasyonID === lok.lokasyonID && styles.lokasyonTextActive
              ]}>
                {lok.lokasyonAdi}
              </Text>
              <Text style={styles.lokasyonSubtext}>{lok.sehirAdi}</Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>

      <View style={styles.card}>
        <Text style={styles.sectionTitle}>İade Lokasyonu</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
          {lokasyonlar.map((lok) => (
            <TouchableOpacity
              key={lok.lokasyonID}
              style={[
                styles.lokasyonButton,
                formData.iadeLokasyonID === lok.lokasyonID && styles.lokasyonButtonActive
              ]}
              onPress={() => setFormData({ ...formData, iadeLokasyonID: lok.lokasyonID })}
            >
              <Text style={[
                styles.lokasyonText,
                formData.iadeLokasyonID === lok.lokasyonID && styles.lokasyonTextActive
              ]}>
                {lok.lokasyonAdi}
              </Text>
              <Text style={styles.lokasyonSubtext}>{lok.sehirAdi}</Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>

      <View style={styles.card}>
        <Text style={styles.sectionTitle}>Tarihler</Text>
        <Text style={styles.infoText}>
           Başlangıç: {formData.baslangicTarihi}
        </Text>
        <Text style={styles.infoText}>
           Bitiş: {formData.bitisTarihi}
        </Text>
        <Text style={styles.infoText}>
           Süre: {gunSayisi} gün
        </Text>
      </View>

      <View style={styles.priceCard}>
        <View style={styles.priceRow}>
          <Text style={styles.priceLabel}>Günlük Ücret:</Text>
          <Text style={styles.priceValue}>₺{arac.gunlukKiraUcreti}</Text>
        </View>
        <View style={styles.priceRow}>
          <Text style={styles.priceLabel}>Gün Sayısı:</Text>
          <Text style={styles.priceValue}>{gunSayisi}</Text>
        </View>
        <View style={styles.divider} />
        <View style={styles.priceRow}>
          <Text style={styles.totalLabel}>TOPLAM:</Text>
          <Text style={styles.totalValue}>₺{toplamTutar}</Text>
        </View>
      </View>

      <TouchableOpacity
        style={[styles.button, submitting && styles.buttonDisabled]}
        onPress={handleSubmit}
        disabled={submitting}
      >
        {submitting ? (
          <ActivityIndicator color="#fff" />
        ) : (
          <Text style={styles.buttonText}>Kirala</Text>
        )}
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
  aracCard: {
    backgroundColor: '#007AFF',
    padding: 20,
    alignItems: 'center',
  },
  aracTitle: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 5,
  },
  aracDetail: {
    fontSize: 14,
    color: '#fff',
    opacity: 0.9,
    marginBottom: 10,
  },
  aracPrice: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#fff',
  },
  card: {
    backgroundColor: '#fff',
    margin: 15,
    marginBottom: 0,
    padding: 15,
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 15,
    color: '#333',
  },
  lokasyonButton: {
    backgroundColor: '#f0f0f0',
    padding: 15,
    borderRadius: 10,
    marginRight: 10,
    minWidth: 150,
  },
  lokasyonButtonActive: {
    backgroundColor: '#007AFF',
  },
  lokasyonText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
    marginBottom: 5,
  },
  lokasyonTextActive: {
    color: '#fff',
  },
  lokasyonSubtext: {
    fontSize: 12,
    color: '#666',
  },
  infoText: {
    fontSize: 16,
    marginBottom: 10,
    color: '#333',
  },
  priceCard: {
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
  priceRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 10,
  },
  priceLabel: {
    fontSize: 16,
    color: '#666',
  },
  priceValue: {
    fontSize: 16,
    fontWeight: '500',
    color: '#333',
  },
  divider: {
    height: 1,
    backgroundColor: '#ddd',
    marginVertical: 10,
  },
  totalLabel: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  totalValue: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#007AFF',
  },
  button: {
    backgroundColor: '#007AFF',
    margin: 15,
    padding: 18,
    borderRadius: 12,
    alignItems: 'center',
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  buttonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
});
