export const Hooks = {
  Flash: {
    mounted() {
      const flashId = this.el.dataset.kind
      setTimeout(() => this.pushEvent("lv:clear-flash", { key: flashId }), 5000)
    },
  },
  Chat: {
    mounted() {
      const chatId = this.el.dataset.chatId

      // Join the chat channel
      this.channel = window.socket.channel(`chat:${chatId}`, {
        userToken: window.__mmState.userToken
      })

      this.channel.join()
        .receive("ok", resp => { console.log(`Joined chat ${chatId} successfully`, resp) })
        .receive("error", resp => { console.log(`Unable to join chat ${chatId}`, resp) })

      // Listen for new messages
      this.channel.on("new_message", (payload) => {
        // Update the LiveView with the new message
        this.pushEventTo(this.el, "new_message", payload)
      })

      // Handle form submission
      const messageForm = this.el.querySelector("#message-form");
      messageForm.addEventListener("submit", (event) => {
        event.preventDefault(); // Prevent the default form submission behavior

        const messageInput = this.el.querySelector("#message-input");

        const messageBody = messageInput.value.trim();
        if (messageBody === "") {
          return;
        }


        // Send the message to the channel
        this.channel.push("new_message", { body: messageBody })
          .receive("ok", (_resp) => {
            messageInput.value = ""; // Clear the input field
          })
          .receive("error", (resp) => {
            console.log("Failed to send message:", resp);
          });
      });
    },

    destroyed() {
      // Leave the channel when the hook is destroyed
      this.channel.leave()
    }
  }
}
