const CACHE_VERSION = 'v1'
const CACHE_NAME = `rastreador-${CACHE_VERSION}`

// Recursos para cachear
const urlsToCache = [
  '/',
  '/manifest',
  // Adicione outros recursos que você quer cachear
]

// Instala o service worker e cacheia recursos iniciais
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('Service Worker: Cache aberto')
        return cache.addAll(urlsToCache)
      })
  )
})

// Ativa o service worker e limpa caches antigos
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('Service Worker: Deletando cache antigo:', cacheName)
            return caches.delete(cacheName)
          }
        })
      )
    })
  )
})

// Intercepta requests e serve do cache quando possível
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        // Retorna do cache se encontrado
        if (response) {
          return response
        }
        // Senão, busca da rede
        return fetch(event.request)
      })
  )
})

// Add a service worker for processing Web Push notifications:
self.addEventListener("push", async (event) => {
  try {
    const data = await event.data.json()
    const { title, options } = data
    event.waitUntil(self.registration.showNotification(title, options))
  } catch (error) {
    console.error('Erro ao processar notificação push:', error)
  }
})

self.addEventListener("notificationclick", function(event) {
  event.notification.close()
  event.waitUntil(
    clients.matchAll({ type: "window" }).then((clientList) => {
      for (let i = 0; i < clientList.length; i++) {
        let client = clientList[i]
        let clientPath = (new URL(client.url)).pathname

        if (clientPath == event.notification.data?.path && "focus" in client) {
          return client.focus()
        }
      }

      if (clients.openWindow) {
        return clients.openWindow(event.notification.data?.path || '/')
      }
    })
  )
})
