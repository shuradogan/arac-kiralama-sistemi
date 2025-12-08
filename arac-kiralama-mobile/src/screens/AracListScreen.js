
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  RefreshControl,
} from 'react-native';
import { aracAPI } from '../services/api';

export default function AracListScreen({ navigation }) {
  const [araclar, setAraclar] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  const loadAraclar = async () => {
    try {
      const response = await aracAPI.getAll();
      if (response.data.success) {
        setAraclar(response.data.data);
      }
    } catch (error) {
      console.error('Araçlar yüklenemedi:', error);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    loadAraclar();
  }, []);

  const onRefresh = () => {
    setRefreshing(true);
    loadAraclar();
  };

  const renderArac = ({ item }) => (
    <TouchableOpacity
      style={styles.card}
      onPress={() => navigation.navigate('AracDetay', { aracID: item.aracID })}
    >
      <View style={styles.cardHeader}>
        <Text style={styles.cardTitle}>
          {item.markaAdi} {item.modelAdi}
        </Text>
        <Text style={styles.cardPrice}>₺{item.gunlukKiraUcreti}/gün</Text>
      </View>
      
      <View style={styles.cardBody}>
        <Text style={styles.cardDetail}> {item.plaka}</Text>
        <Text style={styles.cardDetail}> {item.yil}</Text>
        <Text style={styles.cardDetail}> {item.renk}</Text>
      </View>

      <View style={styles.cardFooter}>
        <View style={[styles.badge, styles.badgeSuccess]}>
          <Text style={styles.badgeText}>{item.durum}</Text>
        </View>
      </View>
    </TouchableOpacity>
  );

  if (loading) {
    return (
      <View style={styles.centerContainer}>
        <ActivityIndicator size="large" color="#007AFF" />
        <Text style={styles.loadingText}>Araçlar yükleniyor...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <FlatList
        data={araclar}
        renderItem={renderArac}
        keyExtractor={(item) => item.aracID.toString()}
        contentContainerStyle={styles.list}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
        ListEmptyComponent={
          <View style={styles.centerContainer}>
            <Text style={styles.emptyText}>Müsait araç bulunamadı</Text>
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
    padding: 20,
  },
  loadingText: {
    marginTop: 10,
    color: '#666',
    fontSize: 16,
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
  cardPrice: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#007AFF',
  },
  cardBody: {
    marginBottom: 10,
  },
  cardDetail: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
  },
  cardFooter: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
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
  emptyText: {
    fontSize: 16,
    color: '#999',
    textAlign: 'center',
  },
});
