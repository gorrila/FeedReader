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

public class FeedReader.InoReaderUtils : GLib.Object {

	private GLib.Settings m_settings;

	public InoReaderUtils()
	{
		m_settings = new GLib.Settings("org.gnome.feedreader.inoreader");
	}

	public string getUser()
	{
		return m_settings.get_string("username");
	}

	public void setUser(string user)
	{
		m_settings.set_string("username", user);
	}

	public string getAccessToken()
	{
		return m_settings.get_string("access-token");
	}

	public void setAccessToken(string token)
	{
		m_settings.set_string("access-token", token);
	}

	public string getUserID()
	{
		return m_settings.get_string("user-id");
	}

	public void setUserID(string id)
	{
		m_settings.set_string("user-id", id);
	}

	public string getEmail()
	{
		return m_settings.get_string("userEmail");
	}

	public void setEmail(string email)
	{
		m_settings.set_string("userEmail", email);
	}

	public string getPasswd()
	{
		var pwSchema = new Secret.Schema ("org.gnome.feedreader.password", Secret.SchemaFlags.NONE,
							                      "Apikey", Secret.SchemaAttributeType.STRING,
							                      "Apisecret", Secret.SchemaAttributeType.STRING,
							                      "Username", Secret.SchemaAttributeType.STRING);
		var attributes = new GLib.HashTable<string,string>(str_hash, str_equal);
		attributes["Apikey"] = getApiKey();
		attributes["Apisecret"] = getApiToken();
		attributes["Username"] = m_settings.get_string("username");

		string passwd = "";
		try
		{
			passwd = Secret.password_lookupv_sync(pwSchema, attributes, null);
		}
		catch(GLib.Error e)
		{
			logger.print(LogMessage.ERROR, "InoReaderUtils: getPasswd: " + e.message);
		}

		if(passwd == null)
		{
			return "";
		}

		return passwd;
	}

	public void setPassword(string passwd)
	{
		var pwSchema = new Secret.Schema ("org.gnome.feedreader.password", Secret.SchemaFlags.NONE,
										  "Apikey", Secret.SchemaAttributeType.STRING,
										  "Apisecret", Secret.SchemaAttributeType.STRING,
										  "Username", Secret.SchemaAttributeType.STRING);
		var attributes = new GLib.HashTable<string,string>(str_hash, str_equal);
		attributes["Apikey"] = getApiKey();
		attributes["Apisecret"] = getApiToken();
		attributes["Username"] = getUser();
		try
		{
			Secret.password_storev_sync(pwSchema, attributes, Secret.COLLECTION_DEFAULT, "Feedserver login", passwd, null);
		}
		catch(GLib.Error e)
		{
			logger.print(LogMessage.ERROR, "InoReaderUtils: setPassword: " + e.message);
		}
	}

	public void resetAccount()
	{
		Utils.resetSettings(m_settings);
		deletePassword();
	}

	public bool deletePassword()
	{
		bool removed = false;
		var pwSchema = new Secret.Schema ("org.gnome.feedreader.password", Secret.SchemaFlags.NONE,
							                      "Apikey", Secret.SchemaAttributeType.STRING,
							                      "Apisecret", Secret.SchemaAttributeType.STRING,
							                      "Username", Secret.SchemaAttributeType.STRING);
		var attributes = new GLib.HashTable<string,string>(str_hash, str_equal);
		attributes["Apikey"] = getApiKey();
		attributes["Apisecret"] = getApiToken();
		attributes["Username"] = m_settings.get_string("username");

		Secret.password_clearv.begin (pwSchema, attributes, null, (obj, async_res) => {
			removed = Secret.password_clearv.end(async_res);
			pwSchema.unref();
		});
		return removed;
	}

	public bool downloadIcon(string feed_id, string icon_url)
	{
		string icon_path = GLib.Environment.get_home_dir() + "/.local/share/feedreader/data/feed_icons/";
		var path = GLib.File.new_for_path(icon_path);
		try{
			path.make_directory_with_parents();
		}
		catch(GLib.Error e){
			//logger.print(LogMessage.DEBUG, e.message);
		}

		string local_filename = icon_path + feed_id.replace("/", "_").replace(".", "_") + ".ico";

		if(!FileUtils.test(local_filename, GLib.FileTest.EXISTS))
		{
			Soup.Message message_dlIcon;
			message_dlIcon = new Soup.Message("GET", icon_url);

			if(settings_tweaks.get_boolean("do-not-track"))
				message_dlIcon.request_headers.append("DNT", "1");

			var session = new Soup.Session();
			session.ssl_strict = false;
			var status = session.send_message(message_dlIcon);
			if (status == 200)
			{
				try{
					FileUtils.set_contents(	local_filename,
											(string)message_dlIcon.response_body.flatten().data,
											(long)message_dlIcon.response_body.length);
				}
				catch(GLib.FileError e)
				{
					logger.print(LogMessage.ERROR, "Error writing icon: %s".printf(e.message));
				}
				return true;
			}
			logger.print(LogMessage.ERROR, "Error downloading icon for feed: %s".printf(feed_id));
			return false;
		}

		// file already exists
		return true;
	}


	public bool tagIsCat(string tagID, Gee.LinkedList<feed> feeds)
	{
		foreach(feed Feed in feeds)
		{
			if(Feed.hasCat(tagID))
			{
				return true;
			}
		}
		return false;
	}

	public string getBaseURI()
	{
		return "https://www.inoreader.com/reader/api/0/";
	}

	public string getApiKey()
	{
		return "1000001058";
	}

	public string getApiToken()
	{
		return "a3LyhdTSKk_dcCygZUZBZenIO2SQcpzz";
	}
}
