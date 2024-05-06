# -*- coding:utf-8 -*-
from flask import Flask, request, jsonify, render_template
import ipinfo
from flask_cors import CORS
from google.cloud import firestore
from user_agents import parse

db = firestore.Client(database='gcp-client-data')
app = Flask(__name__)
CORS(app)


def get_ipinfo(ip_address):
    access_token = '1757f0b2ce3f01'
    handler = ipinfo.getHandler(access_token)
    details = handler.getDetails(ip_address)
    return details

@app.route('/', methods=['GET'])
def index():
    return render_template('index.html')


@app.route('/submit', methods=['POST'])
def submit():
    if request.is_json:
        client_data = request.get_json()
        ua_string = request.headers.get('User-Agent')
        user_agent = parse(ua_string)
        user_agent_list = str(user_agent).split('/')
        device = user_agent_list[0].strip()
        os = user_agent_list[1].strip()
        browser = user_agent_list[2].strip()
        remote_ips = request.headers.get('X-Forwarded-For')
        if remote_ips:
            remote_addr = remote_ips.split(',')[0]
        else:
            remote_addr = request.remote_addr
        details = get_ipinfo(remote_addr)
        # print(details)
        
        data = {}
        id = client_data['id']

        data['client_ip'] = remote_addr
        data['city'] = details.city
        data['country_name'] = details.country_name
        data['loc'] = details.loc
        data['region'] = details.region
        data['dns_time'] = round(client_data['domainLookupEnd'] - client_data['domainLookupStart'],1)
        data['tcp_time'] = round(client_data['connectEnd'] - client_data['connectStart'],1)
        data['http_time'] = round(client_data['responseEnd'] - client_data['requestStart'],1)
        data['domain_url'] = client_data['name']
        data['domain_ip'] = client_data['domain_ip']
        data['duration'] = round(client_data['duration'],1)
        # data['user_agent'] = str(user_agent)
        data['date_time'] = client_data['date_time']
        data['device'] = device
        data['os'] = os
        data['browser'] = browser
        data['x_forward_for'] = str(remote_ips)

        db.collection("performance").document(str(id)).set(data)
        return jsonify({'result':'success'})
    else:
        return jsonify({'error': 'Request data must be JSON'}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
