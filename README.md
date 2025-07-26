# Blocify🎵
Proyecto para la materia Aplicaciones Moviles.

## Descripcion
Proyecto para Aplicaciones Moviles. Un clon de Spotify desarrollado con Flutter que incluye sub-playlists.

## Integrantes
- GUERRA, Lucio.
- ELISECHE, Martin.
- LANZZAVECCHIA CESPEDES, Ignacio.
- WACELINKA, Ariana.

## Requisitos Previos

### 1. Flutter SDK
1. Descargá Flutter desde [flutter.dev](https://flutter.dev/docs/get-started/install/windows)
2. Extraé en `C:\\flutter` y agrega `C:\\flutter\\bin` al PATH
3. Reiniciá tu terminal

### 2. Verificar instalación
```powershell
flutter doctor
```

## Instalación y Ejecución

### 1. Configurar variables de entorno
1. Copia el archivo `.env.example` a `.env`:
```powershell
copy .env.example .env
```

2. Edita el archivo `.env` con tus credenciales de Auth0:
```env
AUTH0_DOMAIN=tu-dominio.auth0.com
AUTH0_CLIENT_ID=tu_client_id
AUTH0_CLIENT_SECRET=tu_client_secret  
AUTH0_CUSTOM_SCHEME=com.example.tuapp
```

**Importante**: Nunca subas el archivo `.env` al repositorio. Ya está incluido en `.gitignore`.

### 2. Instalar dependencias
```powershell
flutter pub get
```

### 3. Correr la aplicación
```powershell
flutter run
```

## Configuración de Auth0

El proyecto utiliza Auth0 para autenticación. Las credenciales se manejan a través de variables de entorno para mayor seguridad.

### Estructura de archivos de configuración:
- `.env` - Variables de entorno (no incluido en git)
- `.env.example` - Plantilla de variables de entorno
- `lib/config/auth0_config.dart` - Configuración de Auth0 que lee las variables de entorno

## Recursos de Flutter

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter Documentation](https://docs.flutter.dev/)

