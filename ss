import requests
from bs4 import BeautifulSoup
from flask import Flask,Response,request
from flask_cors import CORS
import os
import json
import re

path = os.getcwd()
print(path)
port = int(os.getenv("PORT", 3030))
app = Flask(__name__)
CORS(app)

@app.route('/fetch',methods = ['POST'])
def fetchlinks():
    try:
        request_body = request.get_json(force=True)
        keyword = request_body['keyword']
        print("keyword",keyword)
        if re.search(r"\s", keyword):
            keyword.replace(" ", "+")
        links = []
        page = requests.get("https://www.google.com/search?q={}".format(keyword))
        soup = BeautifulSoup(page.content,"html.parser")

        for link in  soup.find_all("a",href=re.compile("(?<=/url\?q=)(htt.*://.*)")):
            links.append(re.split(":(?=http)", link["href"].replace("/url?q=", "")))
        print (links)
        google_links = fetch_links(links)
        result = validate_skill(google_links)
        msg = {"skill": result}
        # returning the result as json
        resp = Response(response=json.dumps(msg),
                        status=200,
                        mimetype="application/json")
        return resp
    except Exception as e:
        print(e)

def fetch_links(links):
    try:
        google_links = []
        for i in links['links']:
            google_links.append(i[0])
        print(google_links)
        return google_links
    except Exception as e:
        print(e)

def validate_skill(google_links):
    try:
        google_links
    except Exception as e:
        print(e)

if __name__ == '__main__':
    app.run(host='0.0.0.0',port=port,threaded=True)
