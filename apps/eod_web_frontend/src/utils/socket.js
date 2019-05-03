import { Socket } from 'phoenix-socket'

export default new Socket(process.env.VUE_APP_SOCKET_URL)
