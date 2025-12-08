
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';


const API_URL = 'http://192.168.1.101:3000/api';

const api = axios.create({
  baseURL: API_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});


api.interceptors.request.use(
  async (config) => {
    const token = await AsyncStorage.getItem('userToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);


export const authAPI = {
  login: (email, sifre) => 
    api.post('/auth/login', { email, sifre }),
  
  register: (userData) => 
    api.post('/auth/register', userData),
};

export const aracAPI = {
  getAll: () => 
    api.get('/araclar'),
  
  getDetay: (aracID) => 
    api.get(`/araclar/${aracID}`),
};


export const kiralamaAPI = {
  yeniKiralama: (kiralamaData) => 
    api.post('/kiralamalar', kiralamaData),
  
  getKiralamalarim: () => 
    api.get('/kiralamalar'),
  
  iptalEt: (kiralamaID) => 
    api.delete(`/kiralamalar/${kiralamaID}`),
  
  getLokasyonlar: () => 
    api.get('/kiralamalar/lokasyonlar'),
};

export const profilAPI = {
  getProfil: () => 
    api.get('/profil'),
  
  updateProfil: (profilData) => 
    api.put('/profil', profilData),
};

export default api;
