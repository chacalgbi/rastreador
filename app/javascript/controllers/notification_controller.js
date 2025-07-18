import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    vehicle: String,
    event: String,
    battery: String,
    relay: String,
    ignition: String,
    odometro: String,
    status: String,
    batbck: String,
    deviceid: String,
    signalgsm: String,
    signalgps: String
  }

  connect() {
    this.showNotification();
  }

  showNotification() {
    let dataHora = new Date().toLocaleString('pt-BR', { timeZone: 'America/Sao_Paulo' })
    let notificationtype = ''

    switch (this.eventValue) {
      case 'commandResult':
        notificationtype = 'info'
        break;
      case 'alarm' || 'powerCut':
        notificationtype = 'error'
        break;
      case 'deviceOffline' || 'deviceUnknown' || 'geofenceExit' || 'deviceOverspeed':
        notificationtype = 'warn'
        break;
      default:
        notificationtype = 'success'
        break;
    }


    $.notify(`${dataHora} 
      ID:${this.deviceidValue}
      Veículo:${this.vehicleValue}
      Evento:${this.eventValue}`,
      {
        autoHideDelay: 15000,
        className: notificationtype
      });
      // Relé:${this.relayValue} Ign:${this.ignitionValue} Odm:${this.odometroValue} Bateria:${this.batteryValue} Gsm:${this.signalgsmValue} Gps:${this.signalgpsValue}
    console.log(`${dataHora} - Veículo:${this.vehicleValue} ID:${this.deviceidValue} Evento:${this.eventValue}`)
  }
}
