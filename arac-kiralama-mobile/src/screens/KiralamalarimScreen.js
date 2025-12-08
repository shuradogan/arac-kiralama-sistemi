
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  RefreshControl,
  Alert,
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';

export default function KiralamalarimScreen({ navigation }) {
  const [kiralamalar, setKiralamalar] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  useEffect(() => {
    loadKiralamalar();
  }, []);

  const loadKiralamalar = async () => {
    try {
      const token = await AsyncStorage.getItem('userToken');
      // IP adresinizi buraya yazın!
      const response = await axios.get('http://192.168.1.101:3000/api/kiralamalar', {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      if (response.data.success) {
        setKiralamalar(response.data.data);
      }
    } catch (error) {
      Alert.alert('Hata', 'Kiralamalar yüklenemedi!');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const onRefresh = () => {
    setRefreshing(true);
    loadKiralamalar();
  };

  const handleIptal = (kiralamaID, aracBilgi) => {
    Alert.alert(
      'Kiralama İptali',
      `${aracBilgi} kiralama işlemini iptal etmek istediğinizden emin misiniz?`,
      [
        { text: 'Vazgeç', style: 'cancel' },
        { text: 'İptal Et', style: 'destructive', onPress: () => iptalEt(kiralamaID) }
      ]
    );
  };

  const iptalEt = async (kiralamaID) => {
    try {
      const token = await AsyncStorage.getItem('userToken');
      const response = await axios.delete(
        `http://192.168.1.101:3000/api/kiralamalar/${kiralamaID}`,
        { headers: { Authorization: `Bearer ${token}` } }
      );

      if (response.data.success) {
        Alert.alert('Başarılı', 'Kiralama iptal edildi!');
        loadKiralamalar();
      }
    } catch (error) {
      Alert.alert('Hata', error.response?.data?.message || 'İptal işlemi başarısız!');
    }
  };

  const getDurumStyle = (durum) => {
    switch (durum) {
      case 'Rezerve':
        return { backgroundColor: '#FFA500' };
      case 'DevamEdiyor':
        return { backgroundColor: '#007AFF' };
      case 'Tamamlandi':
        return { backgroundColor: '#4CAF50' };
      case 'Iptal':
        return { backgroundColor: '#999' };
      default:
        return { backgroundColor: '#666' };
    }
  };

  const renderKiralama = ({ item }) => {
    const baslangic = new Date(item.baslangicTarihi).toLocaleDateString('tr-TR');
    const bitis = new Date(item.bitisTarihi).toLocaleDateString('tr-TR');

    return (
      <View style={styles.card}>
        <View style={styles.cardHeader}>
          <Text style={styles.cardTitle}>
            {item.markaAdi} {item.modelAdi}
          </Text>
          <View style={[styles.badge, getDurumStyle(item.durum)]}>
            <Text style={styles.badgeText}>{item.durum}</Text>
          </View>
        </View>

        <View style={styles.cardBody}>
          <Text style={styles.detail}> {item.plaka}</Text>
          <Text style={styles.detail}> {baslangic} - {bitis}</Text>
          <Text style={styles.detail}> Teslim: {item.teslimLokasyonu}</Text>
          <Text style={styles.detail}> İade: {item.iadeLokasyonu}</Text>
          <Text style={styles.price}>₺{item.toplamTutar}</Text>
        </View>

        {(item.durum === 'Rezerve' || item.durum === 'DevamEdiyor') && (
          <TouchableOpacity
            style={styles.cancelButton}
            onPress={() => handleIptal(item.kiralamaID, `${item.markaAdi} ${item.modelAdi}`)}
          >
            <Text style={styles.cancelButtonText}>İptal Et</Text>
          </TouchableOpacity>
        )}
      </View>
    );
  };

  if (loading) {
    return (
      <View style={styles.centerContainer}>
        <ActivityIndicator size="large" color="#007AFF" />
        <Text style={styles.loadingText}>Yükleniyor...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <FlatList
        data={kiralamalar}
        renderItem={renderKiralama}
        keyExtractor={(item) => item.kiralamaID.toString()}
        contentContainerStyle={styles.list}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>Henüz kiralama yok</Text>
            <TouchableOpacity
              style={styles.button}
              onPress={() => navigation.navigate('Araçlar')}
            >
              <Text style={styles.buttonText}>Araç Kirala</Text>
            </TouchableOpacity>
          </View>
        }
      />
    </View>
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
  loadingText: {
    marginTop: 10,
    color: '#666',
  },
  list: {
    padding: 15,
  },
  card: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 15,
    marginBottom: 15,
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
    marginBottom: 10,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    flex: 1,
  },
  badge: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 15,
  },
  badgeText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: 'bold',
  },
  cardBody: {
    marginBottom: 10,
  },
  detail: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
  },
  price: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#007AFF',
    marginTop: 5,
  },
  cancelButton: {
    backgroundColor: '#FF3B30',
    padding: 12,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 10,
  },
  cancelButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingTop: 100,
  },
  emptyText: {
    fontSize: 16,
    color: '#999',
    marginBottom: 20,
  },
  button: {
    backgroundColor: '#007AFF',
    paddingHorizontal: 30,
    paddingVertical: 15,
    borderRadius: 10,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
});
