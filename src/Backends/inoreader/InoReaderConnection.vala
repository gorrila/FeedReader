//	This file is part of FeedReader.
//
//	FeedReader is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	FeedReader is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with FeedReader.  If not, see <http://www.gnu.org/licenses/>.

public class FeedReader.InoReaderConnection {
	private string m_api_username;
	private string m_api_code;
	private InoReaderUtils m_utils;

	public InoReaderConnection()
	{
		m_utils = new InoReaderUtils();
		m_api_username = m_utils.getUser();
		m_api_code = m_utils.getAccessToken();
	}

	public int getToken()
	{
		var session = new Soup.Session();
		var message = new Soup.Message("POST", "https://www.inoreader.com/accounts/ClientLogin/");
		var pwSchema = new Secret.Schema ("org.gnome.feedreader.password", Secret.SchemaFlags.NONE,
							                      "Apikey", Secret.SchemaAttributeType.STRING,
							                      "Apisecret", Secret.SchemaAttributeType.STRING,
							                      "Username", Secret.SchemaAttributeType.STRING);
		var attributes = new GLib.HashTable<string,string>(str_hash, str_equal);
		attributes["Apikey"] = m_utils.getApiKey();
		attributes["Apisecret"] = m_utils.getApiToken();
		attributes["Username"] = m_api_username;

		string passwd = "";
		try{
			passwd = Secret.password_lookupv_sync(pwSchema, attributes, null);
		}
		catch(GLib.Error e){
			logger.print(LogMessage.ERROR, e.message);
		}

		string message_string = "Email=" + m_api_username + "&Passwd=" + passwd ;
		message.request_headers.append("AppId", m_utils.getApiKey());
		message.request_headers.append("AppKey", m_utils.getApiToken());
		message.set_request("application/x-www-form-urlencoded", Soup.MemoryUse.COPY, message_string.data);
		session.send_message(message);

		try{
			var regex = new Regex(".*\\w\\s.*\\w\\sAuth=");
			string response = (string)message.response_body.flatten().data;
			if(regex.match(response))
			{
				string split = regex.replace( response, -1,0,"");
				m_utils.setAccessToken(split.strip());
				m_api_code = m_utils.getAccessToken();
				return LoginResponse.SUCCESS;
			}
			else
			{
				logger.print(LogMessage.DEBUG, response);
				return LoginResponse.WRONG_LOGIN;
			}
		}
		catch (Error e){
			logger.print(LogMessage.ERROR, "Could not load response to Message from inoreader - %s".printf(e.message));
		}

		return LoginResponse.UNKNOWN_ERROR;
	}

	public string send_request(string path, string? message_string = null)
	{
		return send_post_request(path, "POST", message_string);
	}

	private string send_post_request(string path, string type, string? message_string = null)
	{
		var session = new Soup.Session();
		var message = new Soup.Message(type, m_utils.getBaseURI() + path);

		string inoauth = "GoogleLogin auth=" + m_utils.getAccessToken();

		message.request_headers.append("Authorization", inoauth) ;
		message.request_headers.append("AppId", m_utils.getApiKey());
		message.request_headers.append("AppKey", m_utils.getApiToken());

		if(message_string != null)
			message.set_request("application/x-www-form-urlencoded", Soup.MemoryUse.COPY, message_string.data);

		session.send_message(message);
		return (string)message.response_body.data;
	}

}
