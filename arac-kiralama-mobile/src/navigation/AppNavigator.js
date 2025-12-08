
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';

import LoginScreen from '../screens/LoginScreen';
import RegisterScreen from '../screens/RegisterScreen';
import AracListScreen from '../screens/AracListScreen';
import AracDetayScreen from '../screens/AracDetayScreen';
import KiralamaFormScreen from '../screens/KiralamaFormScreen';
import KiralamalarimScreen from '../screens/KiralamalarimScreen';
import ProfilScreen from '../screens/ProfilScreen';

const Stack = createStackNavigator();
const Tab = createBottomTabNavigator();

function MainTabs() {
  return (
    <Tab.Navigator
      screenOptions={{
        tabBarActiveTintColor: '#007AFF',
        tabBarInactiveTintColor: '#999',
        tabBarStyle: {
          paddingBottom: 5,
          paddingTop: 5,
          height: 60,
        },
      }}
    >
      <Tab.Screen 
        name="Araçlar" 
        component={AracListScreen}
        options={{
          tabBarIcon: () => <Text style={{ fontSize: 24 }}></Text>,
          headerTitle: 'Müsait Araçlar',
        }}
      />
      <Tab.Screen 
        name="Kiralamalarim" 
        component={KiralamalarimScreen}
        options={{
          tabBarIcon: () => <Text style={{ fontSize: 24 }}></Text>,
          headerTitle: 'Kiralamalarim',
        }}
      />
      <Tab.Screen 
        name="Profil" 
        component={ProfilScreen}
        options={{
          tabBarIcon: () => <Text style={{ fontSize: 24 }}></Text>,
          headerTitle: 'Profilim',
        }}
      />
    </Tab.Navigator>
  );
}

export default function AppNavigator() {
  return (
    <NavigationContainer>
      <Stack.Navigator
        screenOptions={{
          headerStyle: {
            backgroundColor: '#007AFF',
          },
          headerTintColor: '#fff',
          headerTitleStyle: {
            fontWeight: 'bold',
          },
        }}
      >
        <Stack.Screen 
          name="Login" 
          component={LoginScreen}
          options={{ headerShown: false }}
        />
        <Stack.Screen 
          name="Register" 
          component={RegisterScreen}
          options={{ 
            title: 'Kayıt Ol',
            headerStyle: { backgroundColor: '#007AFF' },
            headerTintColor: '#fff',
          }}
        />
        <Stack.Screen 
          name="Main" 
          component={MainTabs}
          options={{ headerShown: false }}
        />
        <Stack.Screen 
          name="AracDetay" 
          component={AracDetayScreen}
          options={{ 
            title: 'Araç Detayı',
          }}
        />
        <Stack.Screen 
          name="KiralamaForm" 
          component={KiralamaFormScreen}
          options={{ 
            title: 'Kiralama',
          }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

// Text component import
import { Text } from 'react-native';
