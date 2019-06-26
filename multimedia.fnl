(local music-app "Spotify")

(fn m-key [key]
  (: (hs.eventtap.event.newSystemKeyEvent (string.upper key) true) :post)
  (hs.timer.usleep 5)
  (: (hs.eventtap.event.newSystemKeyEvent (string.upper key) false) :post))

(fn bind [hotkeyMmodal fsm]
  (: hotkeyMmodal :bind nil :a
     (fn []
       (hs.application.launchOrFocus music-app)
       (: fsm :toIdle)))

  (: hotkeyMmodal :bind nil :h (fn [] (m-key :previous) (: fsm :toIdle)))
  (: hotkeyMmodal :bind nil :l (fn [] (m-key :next) (: fsm :toIdle)))
  (let [sup (fn [] (m-key :sound_up))]
    (: hotkeyMmodal :bind nil :k sup nil sup))
  (let [sdn (fn [] (m-key :sound_down))]
    (: hotkeyMmodal :bind nil :j sdn nil sdn))
  (let [pl (fn []
             (m-key :play)
             (: fsm :toIdle))]
    (: hotkeyMmodal :bind nil :s pl)))

(fn add-state [modal]
  (modal.add-state
   :media
   {:from :*
    :init (fn [self, fsm]
            (set self.hotkeyModal (hs.hotkey.modal.new))
            (modal.display-modal-text "h \t previous track\nl \t next track\nk \t volume up\nj \t volume down\ns \t play/pause\na \t launch player")

            (modal.bind
             self
             [:cmd] :space
             (fn [] (: fsm :toMain)))

            (bind self.hotkeyModal fsm)
            (: self.hotkeyModal :enter))}))

{:add-state add-state
 :music-app music-app}
