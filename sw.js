/* Service worker minimal: syarat agar aplikasi bisa dipasang.
   Sengaja TANPA cache supaya perubahan hasil deploy selalu langsung terlihat. */
self.addEventListener("install", function(){ self.skipWaiting(); });
self.addEventListener("activate", function(e){ e.waitUntil(self.clients.claim()); });
self.addEventListener("fetch", function(){ /* diteruskan ke jaringan apa adanya */ });
