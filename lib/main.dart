import 'package:flutter/material.dart';
import 'nebula_bridge.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nebula VPN Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NebulaPage(),
    );
  }
}

class NebulaPage extends StatefulWidget {
  const NebulaPage({Key? key}) : super(key: key);

  @override
  State<NebulaPage> createState() => _NebulaPageState();
}

class _NebulaPageState extends State<NebulaPage> {
  final NebulaBridge _nebulaBridge = NebulaBridge();
  bool _isConnected = false;
  String _status = "Disconnected";
  String _pingResult = "";
  final TextEditingController _pingTargetController = TextEditingController();

  // Your Nebula configuration in YAML format (converted from JSON)
  final String _nebulaConfig = '''
pki:
  ca: |
    -----BEGIN NEBULA CERTIFICATE-----
    CkYKFENPU0dyaWQgTmV0d29ya3MgSW5jKP7v8bkGMP7W9sgGOiC8X6eDBiCOTw7S
    NCbpOjVSzbWhUW/frowc/LfvN5S2j0ABEkAotkfzRmBTcbTraoHNQai092Tjmq3r
    rC9z74dKYFLynxew7F/Q3Zp8+6e8vrksJ60ux4DOXbwgzR8n+UaJweIE
    -----END NEBULA CERTIFICATE-----
  cert: |
    -----BEGIN NEBULA CERTIFICATE-----
    CnkKD1Rlc3RAVGVzdFRlbmFudBIKu4eAogaAgPz/DyIKVGVzdFRlbmFudCjBwMC+
    BjD91vbIBjogtpjUjn00yZCK44fIs+hLvRi7nkSGXBTsUoD9EoVedDZKIOMILLts
    pva1JgGN9p837LZqMHsCVq/unyurPnMbKlHkEkAaIHEH40cCJhYBe9tONjMDK4FA
    DHD26AdAST1sSwDlizl3QVxa5xv0mkiOHqDMydjL5fmXIyjacMu4+7nI2zIn
    -----END NEBULA CERTIFICATE-----
  key: null  # Will be provided at runtime as a separate parameter

static_host_map:
  "100.64.0.1": ["mza.cosgrid.net:4242"]

lighthouse:
  am_lighthouse: false
  serve_dns: false
  interval: 60
  hosts:
    - "100.64.0.1"

listen:
  host: "0.0.0.0"
  port: 4242

punchy:
  punch: true
  respond: true

relay:
  am_relay: false
  use_relays: true
  relays:
    - "100.64.0.1"

tun:
  dev: "ztun-Test"
  drop_local_broadcast: false
  drop_multicast: false
  tx_queue: 500
  mtu: 1300

logging:
  level: "info"
  format: "json"

firewall:
  conntrack:
    tcp_timeout: "120h"
    udp_timeout: "3m"
    default_timeout: "10m"
    max_connections: 100000
  outbound:
    - port: "any"
      proto: "any"
      host: "any"
  inbound:
    - port: "any"
      proto: "icmp"
      host: "any"
      name: "icmp_allow"
      groups: ["TestTenant"]
''';

  // Your Nebula private key
  final String _privateKey = '''
-----BEGIN NEBULA X25519 PRIVATE KEY-----
q8UyTb2Xq3rx6srp/bMH5H3dHJAcz9RvWoX15ezOxbU=
-----END NEBULA X25519 PRIVATE KEY-----
''';

  @override
  void initState() {
    super.initState();
    _pingTargetController.text =
        "100.64.0.1"; // Default ping target to lighthouse
  }

  Future<void> _connectVPN() async {
    setState(() {
      _status = "Connecting...";
    });

    // Skip the test step since the method isn't available
    final success = await _nebulaBridge.startNebula(_nebulaConfig, _privateKey);

    setState(() {
      _isConnected = success;
      _status = success ? "Connected" : "Connection failed";
    });
  }

  Future<void> _disconnectVPN() async {
    setState(() {
      _status = "Disconnecting...";
    });

    final success = await _nebulaBridge.stopNebula();

    setState(() {
      _isConnected = !success;
      _status = success ? "Disconnected" : "Failed to disconnect";
    });
  }

  Future<void> _pingHost() async {
    if (_pingTargetController.text.isEmpty) {
      setState(() {
        _pingResult = "Please enter an IP address";
      });
      return;
    }

    setState(() {
      _pingResult = "Pinging...";
    });

    final success = await _nebulaBridge.pingHost(_pingTargetController.text);

    setState(() {
      _pingResult =
          success
              ? "Ping to ${_pingTargetController.text} was successful"
              : "Ping to ${_pingTargetController.text} failed";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nebula VPN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _isConnected ? Icons.vpn_lock : Icons.vpn_lock_outlined,
                      size: 48,
                      color: _isConnected ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _status,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isConnected ? _disconnectVPN : _connectVPN,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isConnected ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_isConnected ? 'Disconnect' : 'Connect'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Ping Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ping Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _pingTargetController,
                      decoration: const InputDecoration(
                        labelText: 'IP Address',
                        hintText: 'Enter IP to ping',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isConnected ? _pingHost : null,
                      child: const Text('Ping'),
                    ),
                    if (_pingResult.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(_pingResult),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
