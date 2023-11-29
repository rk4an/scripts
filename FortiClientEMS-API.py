import http.client
import json

#Technical Tip: FortiClient EMS Cloud API
#https://community.fortinet.com/t5/FortiClient/Technical-Tip-FortiClient-EMS-Cloud-API/ta-p/218070

def login_to_api(access_key, account_email):
    conn = http.client.HTTPSConnection("forticlient.forticloud.com")
    payload = json.dumps({
        "access_key": access_key,
        "account_email": account_email
    })
    headers = {'Content-type': 'application/json'}

    conn.request("POST", "/fct/api/public/v1/ems_api_cloud/login/", payload, headers)
    res = conn.getresponse()
    data = json.loads(res.read().decode())

    if data.get("result") == "login":
        return data["session_id"]
    else:
        raise ValueError(f"Login failed. Response: {data}")

def get_endpoints(session_id, count):
    conn = http.client.HTTPSConnection("forticlient.forticloud.com")
    headers = {
        'Authorization': session_id,
        'Content-Type': 'application/json'
    }
    endpoint_path = f"/fct/api/public/v1/ems_api/api/v1/endpoints/index?count={count}"

    conn.request("GET", endpoint_path, headers=headers)
    res = conn.getresponse()
    data = json.loads(res.read().decode())

    return data["data"]["endpoints"]

def main():
    access_key = "***********"
    account_email = "***********"
    count = 150

    print("*** Login to API ***")
    try:
        session_id = login_to_api(access_key, account_email)
        print("Login successful.")
        
        print("*** GET Endpoints ***")
        endpoints = get_endpoints(session_id, count)
        
        print("*** Parse JSON ***")
        for endpoint in endpoints:
            computer_name = endpoint["name"]
            ip_address = endpoint["ip_addr"]
            print(f"Computer Name: {computer_name}, IP Address: {ip_address}")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
