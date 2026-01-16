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
    // Gera um ID único para esta notificação baseado no deviceId, event e timestamp
    const notificationId = `${this.deviceidValue}-${this.eventValue}-${Date.now()}`;

    // Verifica se já existe uma notificação com este ID nos últimos 500ms
    if (this.constructor.recentNotifications?.has(notificationId.split('-').slice(0, 2).join('-'))) {
      return; // Evita notificação duplicada
    }

    // Inicializa o Set de notificações recentes se não existir
    if (!this.constructor.recentNotifications) {
      this.constructor.recentNotifications = new Set();
    }

    // Adiciona ao Set e remove após 500ms
    const baseId = `${this.deviceidValue}-${this.eventValue}`;
    this.constructor.recentNotifications.add(baseId);

    setTimeout(() => {
      this.constructor.recentNotifications.delete(baseId);
    }, 500);

    this.showNotification();
  }

  disconnect() {
    // Garante limpeza ao desconectar o controller
    this.element.dataset.notificationConnected = 'false';
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
        autoHideDelay: 10000,
        className: notificationtype
      });
      // Relé:${this.relayValue} Ign:${this.ignitionValue} Odm:${this.odometroValue} Bateria:${this.batteryValue} Gsm:${this.signalgsmValue} Gps:${this.signalgpsValue}
    console.log(`${dataHora} - Veículo:${this.vehicleValue} ID:${this.deviceidValue} Evento:${this.eventValue}`)
  }
}
