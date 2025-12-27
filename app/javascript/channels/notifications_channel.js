import consumer from "./consumer"

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
    console.log("Connected to notifications channel")
  },

  disconnected() {
  },

  received(data) {
    this.showNotification(data)
  },

  showNotification(data) {
    if (window.jQuery && window.jQuery.jGrowl) {
      jQuery.jGrowl(data.message, {
        header: data.title || 'Notification',
        life: 5000,
        theme: data.type || 'success'
      })
    } else {
      console.log('Notification:', data)
    }

    if (data.reload) {
      window.location.reload()
    }
  }
})
