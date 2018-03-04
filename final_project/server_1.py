import asyncio
import codecs
import sys, time, json

class server_propagation_protocol(asyncio.Protocol):
    def __init__(self, message):
        super().__init__()
        self.message = message

    def connection_made(self, transport):
        self.peername = transport.get_extra_info('peername')
        self.log_method('c', log_file, str(self.peername))
        transport.write(self.message.encode())
        self.print_method('sent_from', format(self.message))
        self.log_method('w', log_file, str(self.peername) + ':\n{}'.format(self.message))

    def data_received(self, data):
        self.peername = self.transport.get_extra_info('peername')
        self.print_method('received_from', format(data.decode()))
        self.log_method('r', log_file, str(self.peername) + ':\n{}'.format(self.message))

        super().__init__()

    def log_method(self, choice, log_file, str):
        if choice == 'c':
            log_file.write('\nConnected to ' + str)
        elif choice == 'w':
            log_file.write('\nWrote to ' + str)
        elif choice == 'r':
            log_file.write('\nReceived from ' + str)

    def print_method(self, choice, str):
        if choice == 'sent_from':
            print('Data sent from inter Server: ')
            print(str)
        if choice == 'received_from':
            print('Data received from inter Server: ')
            print(str)

client_cache = dict()

class Servers(asyncio.Protocol):
    def __init__(self, name):
        super().__init__()
        self.name = name

    def connection_made(self, transport):
        self.transport = transport
        self.peername = transport.get_extra_info('peername')
        self.address = transport.get_extra_info('peername')
        self.log_method('c', log_file, str(self.peername))
        self.print_method('sent_from', format(self.name))

    def connection_lost(self, exc):
        self.peername = self.transport.get_extra_info('peername')
        self.log_method('d', log_file, str(self.peername))
        print('Connection lost')

    def log_method(self, choice, log_file, str):
        if choice == 'c':
            log_file.write('\nConnected to ' + str)
        elif choice == 'w':
            log_file.write('\nWrote to ' + str)
        elif choice == 'r':
            log_file.write('\nReceived from ' + str)
        elif choice == 'd':
            log_file.write('\nDisconnected from ' + str)

    def print_method(self, choice, str):
        if choice == 'sent_from':
            print('Data sent from Server: ')
            print(str)
        if choice == 'received_from':
            print('Data received from Server: ')
            print(str)

    def checkIAMATInput(self, data):
        if len(data) != 4:
            return False
        try:
            float(data[3])
            if float(data[3]) < 0:
                raise ValueError
            if not self.valid_location(data[2]):
                print("invalid location")
                raise ValueError
        except ValueError:
            return False
        return True


    def checkATInput(self, data):
        if len(data) != 6:
            return False
        try:
            float(data[5])
            float(data[2])
            if not self.valid_location(data[4]):
                print("invalid location")
                raise ValueError
        except ValueError:
            return False
        return True


    def checkWHATSATInput(self, data):
        if len(data) != 4:
            return False
        if (data[1] not in client_cache):
            return False
        try:
            int(data[2])
            int(data[3])
            if (int(data[2]) > 50 or int(data[2]) < 0):
                raise ValueError
            if (int(data[3]) > 20 or int(data[3]) < 0):
                raise ValueError
        except ValueError:
            return False
        return True

    def data_received(self, data):
        self.peername = self.transport.get_extra_info('peername')
        self.print_method('received_from', format(data.decode()))
        decoded_msg = data.decode()
        log_file.write('\nReceived from ' + str(self.peername) + ':\n{}'.format(decoded_msg))

        split_msg = decoded_msg.split(" ")
        command_to_handle = split_msg[0]
        if len(decoded_msg.split(" ")) < 4:
            self.handle_invalid_data(decoded_msg)
            return
        if command_to_handle == "IAMAT":
            if not self.checkIAMATInput(split_msg):
                self.handle_invalid_data(decoded_msg)
                return
            self.handle_IAMAT_msg(decoded_msg)
        elif command_to_handle == "WHATSAT":
            if not self.checkWHATSATInput(split_msg):
                self.handle_invalid_data(decoded_msg)
                return
            asyncio.Task(self.handle_WHATSAT_msg(decoded_msg))
        elif command_to_handle == "AT":

            if not self.checkATInput(split_msg):
                self.handle_invalid_data(decoded_msg)
                return
            self.handle_AT_msg(decoded_msg)
        else:
            self.handle_invalid_data(decoded_msg)
            return

    def valid_location(self, combined):
        index = 0
        count1 = 0
        count2 = 0
        while index < len(combined):
            val = combined[index]
            if val in ['-','+']: count1 += 1
            if val in ['.']: count2 += 1
            index += 1
        if count1 != 2 or count2 != 2: return False
        temp = combined.replace('+', ' ').replace('-', ' -')
        lat, lng, i = [], [], 0

        while i < len(temp):
            val = combined[i]
            if val in ['-']: break
            i += 1

        lat, lng = combined[:i], combined[i:]

        try:
            temp_lat, temp_lng = float(lat), float(lng)
            if temp_lat > 90 or temp_lat < -90: return False
            if temp_lng > 180 or temp_lng < -180: return False
            return True
        except ValueError:
            return False

    def handle_AT_msg(self, msg):
        self.transport.close()
        split_msg = msg.split(" ")
        client = split_msg[3]
        coords = split_msg[4]
        if client not in client_cache or float(split_msg[5]) > float(client_cache[client][1].split(" ")[5]):
            client_cache[client] = (coords, msg)
            for server in server_associate[self.name]:
                port = port_number[server]
                try:
                    coro = loop.create_connection(lambda: server_propagation_protocol(msg), '127.0.0.1', port)
                    log_file.write("\nconnecting " + server + " to send  " + msg)
                    loop.create_task(coro)
                except:
                    print("Unexpected error:", sys.exc_info()[0])

    def handle_IAMAT_msg(self, msg):
        split_msg = msg.split(" ")
        client = split_msg[1]
        curr_time = time.time()

        if (curr_time > float(split_msg[3])):
            sign = '+'
            time_difference = curr_time - float(split_msg[3])
        else:
            sign = '-'
            time_difference = float(split_msg[3]) - curr_time

        if client in client_cache:
            if float(split_msg[3]) <= float(client_cache[client][1].split(" ")[5]):
                same_response = client_cache[client][1]
                self.transport.write(same_response.encode())
                self.transport.close()
                return

        atmsg = "AT " + self.name + " " + sign + str(time_difference) + " " + " ".join(
            msg.split(" ")[1:])
        self.transport.write(atmsg.encode())
        self.transport.close()
        self.handle_AT_msg(atmsg)

    @asyncio.coroutine
    def handle_WHATSAT_msg(self, msg):
        split_msg = msg.split(" ")
        client = split_msg[1]
        location = client_cache[client][0]
        google_location = location.replace('+', ',').replace('-', ',-').lstrip(',')
        radius = str(1000 * int(split_msg[2]))
        self.bound = int(split_msg[3])
        query = f'key={API_KEY}&location={google_location}&radius={radius}'
        uri = f'/maps/api/place/nearbysearch/json?{query}'
        host = 'maps.googleapis.com'
        request = (f'GET {uri} HTTP/1.1\r\nHost: {host}\r\n'
                   'Content-Type: text/plain; charset=utf-8\r\n\r\n')
        coro = loop.create_connection(lambda: GoogleProtocol(request, self, client), host, 'https', ssl=True)
        loop.create_task(coro)

    def handle_whatsat(self, response, target):
        client = target
        tmp_json = response[response.index('{'):response.rindex('}') + 1]
        load_json = json.loads(tmp_json)
        del load_json['results'][int(self.bound):]
        strjson = json.dumps(load_json, indent=3)
        str_new = ''
        while (str_new != strjson):
            str_new = strjson
            strjson = strjson.replace('\n\n', '\n')
        strjson = strjson + '\n\n'
        split_msg = client_cache[client][1].split(" ")
        result = 'AT {} {} {} {} {}\n{}'.format(split_msg[1], split_msg[2],
                                                client, client_cache[client][0], split_msg[5], strjson)
        log_file.write('\n Server ' + self.name + ' response to whatsat from client: ' + client + ' with the message ' + result)
        self.transport.write(result.encode())
        self.transport.close()

    def handle_invalid_data(self, message):
        self.peername = self.transport.get_extra_info('peername')
        self.transport.write(('? ' + message).encode())
        log_file.write('\nWrote to ' + str(self.peername) + ':\n{}'.format('? ' + message))
        self.transport.close()


class GoogleProtocol(asyncio.Protocol):
    def __init__(self, message, mainprotocol, target):
        self.message = message
        self.prot = mainprotocol
        self.buf = ''
        self.target = target

    def connection_made(self, transport):
        self.transport = transport 
        log_file.write('\nConnected to Google ' + 'with the message ' + self.message)
        transport.write(self.message.encode())

    def data_received(self, data):
        data = data.decode()
        self.buf = self.buf + data
        if (self.buf[len(self.buf) - 4:] == '\r\n\r\n'):
            final_buf = self.preprocess(self.buf)
            self.transport.close()
            loop.call_soon(self.prot.handle_whatsat, final_buf, self.target)

    def preprocess(self, raw):
        raw = raw[7 + raw.find("chunked"):].strip()
        prev = 0
        i = 0
        result = ""
        while i < len(raw):
            if raw[i] == '\r' and raw[i + 1] == '\n':
                end = int(raw[prev:i], 16)
                i = i + 2
                result = result + raw[i:i + end]
                prev = i + end
                i += end
                while i < len(raw) and raw[i] == '\r' and raw[i + 1] == '\n':
                    i += 2
            else:
                i += 1
        return result


API_KEY = 'AIzaSyAkH-JwtsR2tQLm-Oced8ysAZ7_AU-ttuk'

port_number = {
    'Alford': 15300,
    'Ball': 15301,
    'Hamilton': 15302,
    'Holiday': 15303,
    'Welsh': 15304
}

server_associate = {
    'Alford': ['Hamilton', 'Welsh'],
    'Ball': ['Holiday', 'Welsh'],
    'Hamilton': ['Holiday', 'Alford'],
    'Holiday': ['Ball', 'Hamilton'],
    'Welsh': ['Alford', 'Ball']
}

server_name = sys.argv[1]
if (not server_name in server_associate):
    raise Exception(
        'Please input valid server_name, currently server_name is Alford, Ball, Hamilton, Holiday, or Welsh')
with codecs.open(server_name + "_logFile.txt", 'w') as log_file:
    loop = asyncio.get_event_loop()
    coro = loop.create_server(lambda: Servers(server_name), '127.0.0.1', port_number[server_name])
    server = loop.run_until_complete(coro)
    print('Serving on {}'.format(server.sockets[0].getsockname()))
    try:
        loop.run_forever()
    except KeyboardInterrupt:
        pass
    server.close()
    loop.run_until_complete(server.wait_closed())
    log_file.write('\n')
    loop.close()
