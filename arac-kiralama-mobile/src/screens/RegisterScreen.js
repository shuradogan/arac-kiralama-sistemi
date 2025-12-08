
import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Alert,
  ActivityIndicator,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { authAPI } from '../services/api';

export default function RegisterScreen({ navigation }) {
  const [formData, setFormData] = useState({
    tcNo: '',
    ad: '',
    soyad: '',
    telefon: '',
    email: '',
    sifre: '',
    dogumTarihi: '',
    cinsiyet: 'Erkek',
  });
  const [loading, setLoading] = useState(false);

  const handleRegister = async () => {
    const { tcNo, ad, soyad, telefon, email, sifre } = formData;

    if (!tcNo || !ad || !soyad || !telefon || !email || !sifre) {
      Alert.alert('Hata', 'Tüm alanları doldurunuz!');
      return;
    }

    if (tcNo.length !== 11) {
      Alert.alert('Hata', 'TC No 11 haneli olmalıdır!');
      return;
    }

    setLoading(true);
    try {
      const response = await authAPI.register({
        ...formData,
        kullaniciTipi: 'musteri',
      });

      if (response.data.success) {
        Alert.alert('Başarılı', 'Kayıt tamamlandı! Giriş yapabilirsiniz.', [
          { text: 'Tamam', onPress: () => navigation.navigate('Login') },
        ]);
      }
    } catch (error) {
      Alert.alert('Hata', error.response?.data?.message || 'Kayıt başarısız!');
    } finally {
      setLoading(false);
    }
  };

  const updateField = (field, value) => {
    setFormData({ ...formData, [field]: value });
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <Text style={styles.title}> Araç Kiralama</Text>
        <Text style={styles.subtitle}>Kayıt Ol</Text>

        <TextInput
          style={styles.input}
          placeholder="TC No (11 hane)"
          value={formData.tcNo}
          onChangeText={(value) => updateField('tcNo', value)}
          keyboardType="numeric"
          maxLength={11}
        />

        <TextInput
          style={styles.input}
          placeholder="Ad"
          value={formData.ad}
          onChangeText={(value) => updateField('ad', value)}
        />

        <TextInput
          style={styles.input}
          placeholder="Soyad"
          value={formData.soyad}
          onChangeText={(value) => updateField('soyad', value)}
        />

        <TextInput
          style={styles.input}
          placeholder="Telefon (5551234567)"
          value={formData.telefon}
          onChangeText={(value) => updateField('telefon', value)}
          keyboardType="phone-pad"
        />

        <TextInput
          style={styles.input}
          placeholder="Email"
          value={formData.email}
          onChangeText={(value) => updateField('email', value)}
          keyboardType="email-address"
          autoCapitalize="none"
        />

        <TextInput
          style={styles.input}
          placeholder="Şifre"
          value={formData.sifre}
          onChangeText={(value) => updateField('sifre', value)}
          secureTextEntry
        />

        <TextInput
          style={styles.input}
          placeholder="Doğum Tarihi (1990-01-01)"
          value={formData.dogumTarihi}
          onChangeText={(value) => updateField('dogumTarihi', value)}
        />

        <View style={styles.genderContainer}>
          <TouchableOpacity
            style={[
              styles.genderButton,
              formData.cinsiyet === 'Erkek' && styles.genderButtonActive,
            ]}
            onPress={() => updateField('cinsiyet', 'Erkek')}
          >
            <Text
              style={[
                styles.genderText,
                formData.cinsiyet === 'Erkek' && styles.genderTextActive,
              ]}
            >
              Erkek
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[
              styles.genderButton,
              formData.cinsiyet === 'Kadın' && styles.genderButtonActive,
            ]}
            onPress={() => updateField('cinsiyet', 'Kadın')}
          >
            <Text
              style={[
                styles.genderText,
                formData.cinsiyet === 'Kadın' && styles.genderTextActive,
              ]}
            >
              Kadın
            </Text>
          </TouchableOpacity>
        </View>

        <TouchableOpacity
          style={styles.button}
          onPress={handleRegister}
          disabled={loading}
        >
          {loading ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.buttonText}>Kayıt Ol</Text>
          )}
        </TouchableOpacity>

        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Text style={styles.linkText}>
            Zaten hesabınız var mı? <Text style={styles.linkBold}>Giriş Yap</Text>
          </Text>
        </TouchableOpacity>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  scrollContent: {
    padding: 20,
    paddingTop: 40,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 24,
    textAlign: 'center',
    marginBottom: 30,
    color: '#666',
  },
  input: {
    backgroundColor: '#fff',
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
    backgroundColor: '#fff',
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
  buttonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  linkText: {
    textAlign: 'center',
    marginTop: 20,
    color: '#666',
    fontSize: 16,
  },
  linkBold: {
    color: '#007AFF',
    fontWeight: 'bold',
  },
});
