import consumer from "./consumer"

document.addEventListener('turbolinks:load', function() {
  const groupContainer = document.querySelector('[data-group-id]')
  if (!groupContainer) return
  
  const groupId = groupContainer.dataset.groupId
  
  consumer.subscriptions.create(
    { channel: "GroupChannel", group_id: groupId },
    {
      connected() {
        console.log(`Connected to group ${groupId} channel`)
      },

      disconnected() {
      },

      received(data) {
        this.handleNotification(data)
      },

      handleNotification(data) {
        if (window.jQuery && window.jQuery.jGrowl) {
          jQuery.jGrowl(data.message, {
            header: data.title || 'Update',
            life: 5000,
            theme: data.type || 'info'
          })
        }

        if (data.reload) {
          window.location.reload()
        }
      }
    }
  )
})
