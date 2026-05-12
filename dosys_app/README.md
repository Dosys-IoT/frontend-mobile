# Dosys — Mobile App

Aplicación móvil para la plataforma **Dosys**, un sistema inteligente de gestión de medicamentos que se integra con un dispensador IoT físico.

---

## Descripción

Dosys permite a los pacientes monitorear y gestionar su tratamiento farmacológico desde el teléfono. La app se conecta en tiempo real con el dispositivo dispensador a través de la API REST del backend, mostrando estado de compartimentos, alertas de stock, adherencia y lecturas ambientales del dispositivo.

---

## Pantallas implementadas

| Pantalla | Descripción |
|---|---|
| Splash | Pantalla de carga con auto-redirección según sesión activa |
| Login | Autenticación con email y contraseña vía JWT |
| Home | Dashboard con próxima dosis, schedule del día, estado del dispositivo y humedad |
| Medications | Lista de medicamentos activos con progreso de stock y adherencia semanal |
| Add Medication | Formulario para asignar un medicamento a un compartimento del dispensador |
| Edit Medication | Edición de nombre, dosis, horarios y alertas de un medicamento |
| Dose Alert | Pantalla de alerta cuando una dosis está programada para ahora |
| Device | Estado del hardware: conectividad, humedad interna, estado de compartimentos |
| Insights | Métricas de adherencia mensual, tendencia semanal, salud de almacenamiento y predicción de refill |
| Alerts | Centro de notificaciones operacionales (stock bajo, humedad alta, tratamientos por vencer) |

---

## Stack técnico

- **Flutter** — framework UI multiplataforma
- **go_router** — navegación declarativa
- **http** — cliente HTTP para la API REST
- **shared_preferences** — persistencia local del JWT
- **google_fonts** — tipografía (Inter)

---

## Estructura del proyecto

```
lib/
├── main.dart
├── core/
│   ├── network/         # ApiClient (GET, POST, PUT, DELETE + JWT)
│   └── theme/           # Colores y tema global (AppColors, AppTheme)
├── features/
│   ├── auth/            # Login, Splash, AuthService
│   ├── home/            # Dashboard principal
│   ├── medications/     # Lista, agregar, editar, alerta de dosis
│   ├── device/          # Estado del hardware IoT
│   └── insights/        # Métricas y alertas
├── router/              # Definición de rutas con go_router
└── shared/
    └── widgets/         # BottomNavBar compartida
```

---

## Configuración

### Requisitos

- Flutter `^3.11.5`
- Dart `^3.11.5`
- Backend Dosys corriendo en `localhost:8080`

### Instalación

```bash
cd dosys_app
flutter pub get
```

### Correr la app

```bash
# En Chrome (desarrollo — CORS deshabilitado necesario)
flutter run -d chrome --web-browser-flag "--disable-web-security"

# En Windows
flutter run -d windows

# En Android/iOS (con emulador o dispositivo conectado)
flutter run
```

### URL del backend

El `baseUrl` está definido en [lib/core/network/api_client.dart](lib/core/network/api_client.dart):

```dart
static const baseUrl = 'http://localhost:8080';
```

Cámbialo por la IP o dominio del servidor según el entorno.

---

## API utilizada

La app consume la API REST de Dosys Platform (`v1`). Endpoints principales:

- `POST /api/v1/access/login` — autenticación
- `GET /api/v1/medication/devices` — lista de dispositivos del usuario
- `GET /api/v1/medication/devices/{id}/containers` — compartimentos
- `GET /api/v1/medication/devices/{id}/schedules` — horarios de dosis
- `GET /api/v1/medication/devices/{id}/environment/latest` — humedad y temperatura
- `PUT /api/v1/medication/devices/{id}/containers/{num}` — actualizar compartimento

---

## Curso

**Universidad Peruana de Ciencias Aplicadas (UPC)**  
Internet of Things — 2026-1  
Trabajo Final
