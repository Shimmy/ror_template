import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="docker"
export default class extends Controller {
  static targets = ["output"];

  send(event) {
    const action = event.target.dataset.actionName;
    const url = event.target.dataset.url;

    fetch(url, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "text/vnd.turbo-stream.html, text/html, application/xhtml+xml"
      },
      credentials: "same-origin"
    })
    .then(response => response.ok ? response.text() : Promise.reject(response))
    .then(html => {
      if(this.hasOutputTarget) {
        this.outputTarget.innerHTML = `✔️ ${action.replace('_', ' ')} complete.`;
      }
    })
    .catch(_err => {
      if(this.hasOutputTarget) {
        this.outputTarget.innerHTML = `❌ Something went wrong.`;
      }
    });
  }
}
