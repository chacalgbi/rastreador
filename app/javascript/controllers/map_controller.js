import { Controller } from "@hotwired/stimulus"
import * as L from "leaflet"

export default class extends Controller {
  static values = {
    latitude: { type: Number, default: -14.1000 },
    longitude: { type: Number, default: -42.1000 },
    zoom: { type: Number, default: 13 },
    popup: { type: String, default: "Error" }
  }

  connect() {
    this.initializeMap()
    this.element.addEventListener("map:show", this.handleShow.bind(this))
  }

  initializeMap() {
    this.map = L.map(this.element).setView([this.latitudeValue, this.longitudeValue], this.zoomValue)

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: ''
    }).addTo(this.map)

    L.marker([this.latitudeValue, this.longitudeValue]).addTo(this.map)
      .bindPopup(this.popupValue)
      .openPopup()

    setTimeout(() => {
      this.map.invalidateSize()
    }, 100)
  }

  handleShow() {
    setTimeout(() => {
      this.map.invalidateSize()
    }, 50)
  }

  disconnect() {
    this.element.removeEventListener("map:show", this.handleShow.bind(this))
    if (this.map) {
      this.map.remove()
    }
  }
}
