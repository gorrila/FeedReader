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

public class FeedReader.FeedServer : GLib.Object {
	private ttrssInterface m_ttrss;
	private feedlyInterface m_feedly;
	private OwncloudNewsInterface m_owncloud;
	private InoReaderInterface m_inoreader;
	private int m_type;
	public signal void newFeedList();
	public signal void updateFeedList();
	public signal void updateArticleList();
	public signal void writeInterfaceState();
	public signal void showArticleListOverlay();

	public FeedServer(Backend type)
	{
		m_type = type;
		logger.print(LogMessage.DEBUG, "FeedServer: new with type %i".printf(type));

		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss = new ttrssInterface();
				m_ttrss.updateFeedList.connect(() => {updateFeedList();});
				m_ttrss.updateArticleList.connect(() => {updateArticleList();});
				m_ttrss.writeInterfaceState.connect(() => {writeInterfaceState();});
				m_ttrss.setNewRows.connect((before) => {setNewRows(before);});
				break;

			case Backend.FEEDLY:
				m_feedly = new feedlyInterface();
				m_feedly.updateFeedList.connect(() => {updateFeedList();});
				m_feedly.updateArticleList.connect(() => {updateArticleList();});
				m_feedly.writeArticlesInChunks.connect((articles, chunksize) => {
					writeArticlesInChunks(articles, chunksize);
				});
				break;

			case Backend.OWNCLOUD:
				m_owncloud = new OwncloudNewsInterface();
				m_owncloud.updateFeedList.connect(() => {updateFeedList();});
				m_owncloud.updateArticleList.connect(() => {updateArticleList();});
				m_owncloud.writeArticlesInChunks.connect((articles, chunksize) => {
					writeArticlesInChunks(articles, chunksize);
				});
				break;
			case Backend.INOREADER:
				m_inoreader = new InoReaderInterface();
				m_inoreader.updateFeedList.connect(() => {updateFeedList();});
				m_inoreader.updateArticleList.connect(() => {updateArticleList();});
				m_inoreader.writeArticlesInChunks.connect((articles, chunksize) => {
					writeArticlesInChunks(articles, chunksize);
				});
				break;
		}
	}

	public int getType()
	{
		return m_type;
	}

	public bool supportTags()
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				return m_ttrss.supportTags();

			case Backend.FEEDLY:
				return m_feedly.supportTags();

			case Backend.INOREADER:
				return m_inoreader.supportTags();

			case Backend.OWNCLOUD:
				return m_owncloud.supportTags();

			default:
				return false;
		}
	}

	public string? symbolicIcon()
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				return m_ttrss.symbolicIcon();

			case Backend.FEEDLY:
				return m_feedly.symbolicIcon();

			case Backend.INOREADER:
				return m_inoreader.symbolicIcon();

			case Backend.OWNCLOUD:
				return m_owncloud.symbolicIcon();

			case Backend.NONE:
			default:
				return null;
		}
	}

	public string? accountName()
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				return m_ttrss.accountName();

			case Backend.FEEDLY:
				return m_feedly.accountName();

			case Backend.INOREADER:
				return m_inoreader.accountName();

			case Backend.OWNCLOUD:
				return m_owncloud.accountName();

			case Backend.NONE:
			default:
				return null;
		}
	}

	public string? getServerURL()
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				return m_ttrss.getServer();

			case Backend.OWNCLOUD:
				return m_owncloud.getServer();

			case Backend.INOREADER:
				return m_inoreader.getServer();

			case Backend.FEEDLY:
				return m_feedly.getServer();

			case Backend.NONE:
			default:
				return null;
		}
	}

	public string uncategorizedID()
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				return m_ttrss.uncategorizedID();

			case Backend.OWNCLOUD:
				return m_owncloud.uncategorizedID();

			case Backend.INOREADER:
				return m_inoreader.uncategorizedID();

			case Backend.FEEDLY:
				return m_feedly.uncategorizedID();

			default:
				return "";
		}
	}

	public bool hideCagetoryWhenEmtpy(string catID)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				return m_ttrss.hideCagetoryWhenEmtpy(catID);

			case Backend.OWNCLOUD:
				return m_owncloud.hideCagetoryWhenEmtpy(catID);

			case Backend.INOREADER:
				return m_inoreader.hideCagetoryWhenEmtpy(catID);

			case Backend.FEEDLY:
				return m_feedly.hideCagetoryWhenEmtpy(catID);

			default:
				return false;
		}
	}

	public bool supportMultiLevelCategories()
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				return m_ttrss.supportMultiLevelCategories();

			case Backend.FEEDLY:
				return m_feedly.supportMultiLevelCategories();

			case Backend.INOREADER:
				return m_inoreader.supportMultiLevelCategories();

			case Backend.OWNCLOUD:
				return m_owncloud.supportMultiLevelCategories();

			default:
				return false;
		}
	}

	public bool supportMultiCategoriesPerFeed()
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				return m_ttrss.supportMultiCategoriesPerFeed();

			case Backend.FEEDLY:
				return m_feedly.supportMultiCategoriesPerFeed();

			case Backend.INOREADER:
				return m_inoreader.supportMultiCategoriesPerFeed();

			case Backend.OWNCLOUD:
				return m_owncloud.supportMultiCategoriesPerFeed();

			default:
				return false;
		}
	}

	// some backends (inoreader, feedly) have the tag-name as part of the ID
	// but for some of them the tagID changes when the name was changed (inoreader)
	public bool tagIDaffectedByNameChange()
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				return m_ttrss.tagIDaffectedByNameChange();

			case Backend.FEEDLY:
				return m_feedly.tagIDaffectedByNameChange();

			case Backend.INOREADER:
				return m_inoreader.tagIDaffectedByNameChange();

			case Backend.OWNCLOUD:
				return m_owncloud.tagIDaffectedByNameChange();

			default:
				return false;
		}
	}

	public void resetAccount()
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.resetAccount();
				break;

			case Backend.FEEDLY:
				m_feedly.resetAccount();
				break;

			case Backend.INOREADER:
				m_inoreader.resetAccount();
				break;

			case Backend.OWNCLOUD:
				m_owncloud.resetAccount();
				break;
		}
	}

	// whether or not to use the "max-articles"-setting
	public bool useMaxArticles()
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				return m_ttrss.useMaxArticles();

			case Backend.FEEDLY:
				return m_feedly.useMaxArticles();

			case Backend.INOREADER:
				return m_inoreader.useMaxArticles();

			case Backend.OWNCLOUD:
				return m_owncloud.useMaxArticles();

			default:
				return true;
		}
	}

	public LoginResponse login()
	{
		switch(m_type)
		{
			case Backend.NONE:
				return LoginResponse.NO_BACKEND;

			case Backend.TTRSS:
				return m_ttrss.login();

			case Backend.FEEDLY:
				return m_feedly.login();

			case Backend.OWNCLOUD:
				return m_owncloud.login();

			case Backend.INOREADER:
				return m_inoreader.login();
		}
		return LoginResponse.UNKNOWN_ERROR;
	}

	public bool logout()
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				return m_ttrss.logout();

			case Backend.FEEDLY:
				return m_feedly.logout();

			case Backend.OWNCLOUD:
				return m_owncloud.logout();

			case Backend.INOREADER:
				return m_inoreader.logout();
				break;
		}

		return false;
	}

	public void syncContent()
	{
		if(!serverAvailable())
		{
			logger.print(LogMessage.DEBUG, "FeedServer: can't snyc - not logged in or unreachable");
			return;
		}

		int before = dataBase.getHighestRowID();

		var categories = new Gee.LinkedList<category>();
		var feeds      = new Gee.LinkedList<feed>();
		var tags       = new Gee.LinkedList<tag>();

		getFeedsAndCats(feeds, categories, tags);

		// write categories
		dataBase.reset_exists_flag();
		dataBase.write_categories(categories);
		dataBase.delete_nonexisting_categories();

		// write feeds
		dataBase.reset_subscribed_flag();
		dataBase.write_feeds(feeds);
		dataBase.delete_articles_without_feed();
		dataBase.delete_unsubscribed_feeds();

		// write tags
		dataBase.reset_exists_tag();
		dataBase.write_tags(tags);
		dataBase.update_tags(tags);
		dataBase.delete_nonexisting_tags();

		newFeedList();

		int unread = getUnreadCount();
		int max = ArticleSyncCount();

		if(unread > max && useMaxArticles())
		{
			getArticles(20, ArticleStatus.MARKED);
			getArticles(unread, ArticleStatus.UNREAD);
		}
		else
		{
			getArticles(max);
		}


		//update fulltext table
		dataBase.updateFTS();

		int after = dataBase.getHighestRowID();
		int newArticles = after-before;
		if(newArticles > 0)
		{
			sendNotification(newArticles);
			showArticleListOverlay();
		}

		switch(settings_general.get_enum("drop-articles-after"))
		{
			case DropArticles.NEVER:
	            break;

			case DropArticles.ONE_WEEK:
				dataBase.dropOldArtilces(1);
				break;

			case DropArticles.ONE_MONTH:
				dataBase.dropOldArtilces(4);
				break;

			case DropArticles.SIX_MONTHS:
				dataBase.dropOldArtilces(24);
				break;
		}

		var now = new DateTime.now_local();
		settings_state.set_int("last-sync", (int)now.to_unix());

		dataBase.checkpoint();

		return;
	}

	public void InitSyncContent()
	{
		logger.print(LogMessage.DEBUG, "FeedServer: initial sync");

		var categories = new Gee.LinkedList<category>();
		var feeds      = new Gee.LinkedList<feed>();
		var tags       = new Gee.LinkedList<tag>();

		getFeedsAndCats(feeds, categories, tags);

		// write categories
		dataBase.write_categories(categories);

		// write feeds
		dataBase.write_feeds(feeds);

		// write tags
		dataBase.write_tags(tags);

		newFeedList();

		// get marked articles
		getArticles(settings_general.get_int("max-articles"), ArticleStatus.MARKED);

		// get articles for each tag
		foreach(var tag_item in tags)
		{
			getArticles((settings_general.get_int("max-articles")/8), ArticleStatus.ALL, tag_item.getTagID(), true);
		}

		if(useMaxArticles())
		{
			//get max-articls amunt like normal sync
			getArticles(settings_general.get_int("max-articles"));
		}

		// get unread articles
		getArticles(getUnreadCount(), ArticleStatus.UNREAD);

		//update fulltext table
		dataBase.updateFTS();

		settings_general.reset("content-grabber");

		var now = new DateTime.now_local();
		settings_state.set_int("last-sync", (int)now.to_unix());

		return;
	}


	public void setArticleIsRead(string articleIDs, ArticleStatus read)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.setArticleIsRead(articleIDs, read);
				break;

			case Backend.FEEDLY:
				m_feedly.setArticleIsRead(articleIDs, read);
				break;

			case Backend.OWNCLOUD:
				m_owncloud.setArticleIsRead(articleIDs, read);
				break;

			case Backend.INOREADER:
				m_inoreader.setArticleIsRead(articleIDs, read);
				break;
		}
	}

	public void setArticleIsMarked(string articleID, ArticleStatus marked)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.setArticleIsMarked(articleID, marked);
				break;

			case Backend.FEEDLY:
				m_feedly.setArticleIsMarked(articleID, marked);
				break;

			case Backend.OWNCLOUD:
				m_owncloud.setArticleIsMarked(articleID, marked);
				break;

			case Backend.INOREADER:
				m_inoreader.setArticleIsMarked(articleID, marked);
				break;
		}
	}

	public void setFeedRead(string feedID)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.setFeedRead(feedID);
				break;

			case Backend.FEEDLY:
				m_feedly.setFeedRead(feedID);
				break;

			case Backend.OWNCLOUD:
				m_owncloud.setFeedRead(feedID);
				break;

			case Backend.INOREADER:
				m_inoreader.setFeedRead(feedID);
				break;
		}
	}

	public void setCategorieRead(string catID)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.setCategorieRead(catID);
				break;

			case Backend.FEEDLY:
				m_feedly.setCategorieRead(catID);
				break;

			case Backend.OWNCLOUD:
				m_owncloud.setCategorieRead(catID);
				break;

			case Backend.INOREADER:
				m_inoreader.setCategorieRead(catID);
				break;
		}
	}

	public void markAllItemsRead()
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.markAllItemsRead();
				break;

			case Backend.FEEDLY:
				m_feedly.markAllItemsRead();
				break;

			case Backend.OWNCLOUD:
				m_owncloud.markAllItemsRead();
				break;

			case Backend.INOREADER:
				m_inoreader.markAllItemsRead();
				break;
		}
	}


	public void tagArticle(string articleID, string tagID)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.tagArticle(articleID, tagID);
				break;

			case Backend.FEEDLY:
				m_feedly.tagArticle(articleID, tagID);
				break;

			case Backend.INOREADER:
				m_inoreader.tagArticle(articleID, tagID);
				break;
		}
	}


	public void removeArticleTag(string articleID, string tagID)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.removeArticleTag(articleID, tagID);
				break;

			case Backend.FEEDLY:
				m_feedly.removeArticleTag(articleID, tagID);
				break;

			case Backend.INOREADER:
				m_inoreader.removeArticleTag(articleID, tagID);
				break;
		}
	}

	public string createTag(string caption)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				return m_ttrss.createTag(caption);

			case Backend.FEEDLY:
				return m_feedly.createTag(caption);

			case Backend.INOREADER:
				return m_inoreader.createTag(caption);
		}

		return ":(";
	}

	public void deleteTag(string tagID)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.deleteTag(tagID);
				break;

			case Backend.FEEDLY:
				m_feedly.deleteTag(tagID);
				break;

			case Backend.OWNCLOUD:
				m_owncloud.deleteTag(tagID);
				break;

			case Backend.INOREADER:
				m_inoreader.deleteTag(tagID);
				break;
		}
	}

	public void renameTag(string tagID, string title)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.renameTag(tagID, title);
				break;
			case Backend.FEEDLY:
				m_feedly.renameTag(tagID, title);
				break;

			case Backend.INOREADER:
				m_inoreader.renameTag(tagID, title);
				break;
		}
	}

	public bool serverAvailable()
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				return m_ttrss.serverAvailable();

			case Backend.FEEDLY:
				return m_feedly.serverAvailable();

			case Backend.OWNCLOUD:
				return m_owncloud.serverAvailable();

			case Backend.INOREADER:
				return m_inoreader.serverAvailable();
		}

		return false;
	}

	public void addFeed(string feedURL, string? catID = null, string? newCatName = null)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.addFeed(feedURL, catID, newCatName);
				break;

			case Backend.FEEDLY:
				m_feedly.addFeed(feedURL, catID, newCatName);
				break;

			case Backend.OWNCLOUD:
				m_owncloud.addFeed(feedURL, catID, newCatName);
				break;

			case Backend.INOREADER:
				m_inoreader.addFeed(feedURL, catID, newCatName);
				break;
		}
	}

	public void removeFeed(string feedID)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.removeFeed(feedID);
				break;

			case Backend.FEEDLY:
				m_feedly.removeFeed(feedID);
				break;

			case Backend.OWNCLOUD:
				m_owncloud.removeFeed(feedID);
				break;

			case Backend.INOREADER:
				m_inoreader.removeFeed(feedID);
				break;
		}
	}

	public void renameFeed(string feedID, string title)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.renameFeed(feedID, title);
				break;

			case Backend.FEEDLY:
				m_feedly.renameFeed(feedID, title);
				break;

			case Backend.OWNCLOUD:
				m_owncloud.renameFeed(feedID, title);
				break;

			case Backend.INOREADER:
				m_inoreader.renameFeed(feedID, title);
				break;
		}
	}

	public void moveFeed(string feedID, string newCatID, string? currentCatID = null)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.moveFeed(feedID, newCatID, currentCatID);
				break;

			case Backend.FEEDLY:
				m_feedly.moveFeed(feedID, newCatID, currentCatID);
				break;

			case Backend.OWNCLOUD:
				m_owncloud.moveFeed(feedID, newCatID, currentCatID);
				break;

			case Backend.INOREADER:
				m_inoreader.moveFeed(feedID, newCatID, currentCatID);
				break;
		}
	}

	public string createCategory(string title, string? parentID = null)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				return m_ttrss.createCategory(title, parentID);

			case Backend.FEEDLY:
				return m_feedly.createCategory(title, parentID);

			case Backend.OWNCLOUD:
				return m_owncloud.createCategory(title, parentID);

			case Backend.INOREADER:
				return m_inoreader.createCategory(title, parentID);
		}

		return "fail";
	}

	public void renameCategory(string catID, string title)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.renameCategory(catID, title);
				break;

			case Backend.FEEDLY:
				m_feedly.renameCategory(catID, title);
				break;

			case Backend.OWNCLOUD:
				m_owncloud.renameCategory(catID, title);
				break;

			case Backend.INOREADER:
				m_inoreader.renameCategory(catID, title);
				break;
		}
	}

	public void moveCategory(string catID, string newParentID)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.moveCategory(catID, newParentID);
				break;

			case Backend.FEEDLY:
				m_feedly.moveCategory(catID, newParentID);
				break;

			case Backend.OWNCLOUD:
				m_owncloud.moveCategory(catID, newParentID);
				break;

			case Backend.INOREADER:
				m_inoreader.moveCategory(catID, newParentID);
				break;
		}
	}

	public void deleteCategory(string catID)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.deleteCategory(catID);
				break;

			case Backend.FEEDLY:
				m_feedly.deleteCategory(catID);
				break;

			case Backend.OWNCLOUD:
				m_owncloud.deleteCategory(catID);
				break;

			case Backend.INOREADER:
				m_inoreader.deleteCategory(catID);
				break;
		}
	}

	public void removeCatFromFeed(string feedID, string catID)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.removeCatFromFeed(feedID, catID);
				break;

			case Backend.OWNCLOUD:
				m_owncloud.removeCatFromFeed(feedID, catID);
				break;

			case Backend.INOREADER:
				m_inoreader.removeCatFromFeed(feedID, catID);
				break;

			// only feedly supports multiple categories atm
			case Backend.FEEDLY:
				m_feedly.removeCatFromFeed(feedID, catID);
				break;
		}
	}

	public void importOPML(string opml)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.importOPML(opml);
				break;

			case Backend.OWNCLOUD:
				m_ttrss.importOPML(opml);
				break;

			case Backend.INOREADER:
				m_inoreader.importOPML(opml);
				break;

			case Backend.FEEDLY:
				m_feedly.importOPML(opml);
				break;
		}
	}

	private void getFeedsAndCats(Gee.LinkedList<feed> feeds, Gee.LinkedList<category> categories, Gee.LinkedList<tag> tags)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.getFeedsAndCats(feeds, categories, tags);
				return;

			case Backend.FEEDLY:
				m_feedly.getFeedsAndCats(feeds, categories, tags);
				return;

			case Backend.OWNCLOUD:
				m_owncloud.getFeedsAndCats(feeds, categories, tags);
				return;

			case Backend.INOREADER:
				m_inoreader.getFeedsAndCats(feeds, categories, tags);
				return;
		}
	}

	private int getUnreadCount()
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				return m_ttrss.getUnreadCount();

			case Backend.FEEDLY:
				return m_feedly.getUnreadCount();

			case Backend.OWNCLOUD:
				return m_owncloud.getUnreadCount();

			case Backend.INOREADER:
				return m_inoreader.getUnreadCount();
		}

		return 0;
	}

	private void getArticles(int count, ArticleStatus whatToGet = ArticleStatus.ALL, string? feedID = null, bool isTagID = false)
	{
		switch(m_type)
		{
			case Backend.TTRSS:
				m_ttrss.getArticles(count, whatToGet, feedID, isTagID);
				break;

			case Backend.FEEDLY:
				m_feedly.getArticles(count, whatToGet, feedID, isTagID);
				break;

			case Backend.OWNCLOUD:
				m_owncloud.getArticles(count, whatToGet, feedID, isTagID);
				break;

			case Backend.INOREADER:
				m_inoreader.getArticles(count, whatToGet, feedID, isTagID);
				break;
		}
	}

	private void writeArticlesInChunks(Gee.LinkedList<article> articles, int chunksize)
	{
		if(articles.size > 0)
		{
			string last = articles.first().getArticleID();
			dataBase.update_articles(articles);
			updateFeedList();
			updateArticleList();
			var new_articles = new Gee.LinkedList<article>();

			var it = articles.bidir_list_iterator();
			for (var has_next = it.last(); has_next; has_next = it.previous())
			{
				article Article = it.get();
				FeedServer.grabContent(Article);
				new_articles.add(Article);

				if(new_articles.size == chunksize || Article.getArticleID() == last)
				{
					int before = dataBase.getHighestRowID();
					dataBase.write_articles(new_articles);
					new_articles = new Gee.LinkedList<article>();
					setNewRows(before);
				}
			}
		}
	}

	private void setNewRows(int before)
	{
		int after = dataBase.getHighestRowID();
		int newArticles = after-before;

		if(newArticles > 0)
		{
			logger.print(LogMessage.DEBUG, "FeedServer: new articles: %i".printf(newArticles));
			writeInterfaceState();
			updateFeedList();
			updateArticleList();

			if(settings_state.get_boolean("no-animations"))
			{
				logger.print(LogMessage.DEBUG, "UI NOT running: setting \"articlelist-new-rows\"");
				int newCount = settings_state.get_int("articlelist-new-rows") + (int)Utils.getRelevantArticles(newArticles);
				settings_state.set_int("articlelist-new-rows", newCount);
			}
		}
	}


	private void sendNotification(uint newArticles)
	{
		try{
			string message = "";
			string summary = _("New Articles");
			uint unread = dataBase.get_unread_total();

			if(!Notify.is_initted())
			{
				logger.print(LogMessage.ERROR, "notification: libnotifiy not initialized");
				return;
			}

			if(newArticles > 0)
			{
				if(unread == 1)
					message = _("There is 1 new article (%u unread)").printf(unread);
				else
					message = _("There are %u new articles (%u unread)").printf(newArticles, unread);


				if(notification == null)
				{
					notification = new Notify.Notification(summary, message, AboutInfo.iconName);
					notification.set_urgency(Notify.Urgency.NORMAL);
					notification.set_app_name(AboutInfo.programmName);
					notification.set_hint("desktop-entry", new Variant ("(s)", "feedreader"));

					if(m_notifyActionSupport)
					{
						notification.add_action ("default", "Show FeedReader", (notification, action) => {
							logger.print(LogMessage.DEBUG, "notification: default action");
							try {
								notification.close();
							} catch (Error e) {
								logger.print(LogMessage.ERROR, e.message);
							}

							string[] spawn_args = {"feedreader"};
							try{
								GLib.Process.spawn_async("/", spawn_args, null , GLib.SpawnFlags.SEARCH_PATH, null, null);
							}catch(GLib.SpawnError e){
								logger.print(LogMessage.ERROR, "spawning command line: %s".printf(e.message));
							}
						});
					}
				}
				else
				{
					notification.update(summary, message, AboutInfo.iconName);
				}

				notification.show();
			}
		}catch (GLib.Error e) {
			logger.print(LogMessage.ERROR, e.message);
		}
	}


	public static void grabContent(article Article)
	{
		if(!dataBase.article_exists(Article.getArticleID()))
		{
			if(settings_general.get_boolean("content-grabber"))
			{
				var grabber = new Grabber(Article.getURL(), Article.getArticleID(), Article.getFeedID());
				if(grabber.process())
				{
					grabber.print();
					if(Article.getAuthor() != "" && grabber.getAuthor() != null)
					{
						Article.setAuthor(grabber.getAuthor());
					}
					if(Article.getTitle() != "" && grabber.getTitle() != null)
					{
						Article.setTitle(grabber.getTitle());
					}
					string html = grabber.getArticle();
					string xml = "<?xml";

					while(html.has_prefix(xml))
					{
						int end = html.index_of_char('>');
						html = html.slice(end+1, html.length).chug();
					}

					Article.setHTML(html);

					return;
				}
			}

			downloadImages(Article);
		}
	}

	private static void downloadImages(article Article)
	{
		var html_cntx = new Html.ParserCtxt();
        html_cntx.use_options(Html.ParserOption.NOERROR + Html.ParserOption.NOWARNING);
        Html.Doc* doc = html_cntx.read_doc(Article.getHTML(), "");
        if (doc == null)
        {
            logger.print(LogMessage.DEBUG, "Grabber: parsing failed");
    		return;
    	}
		grabberUtils.repairURL("//img", "src", doc, Article.getURL());
		grabberUtils.stripNode(doc, "//a[not(node())]");
		grabberUtils.removeAttributes(doc, null, "style");
        grabberUtils.removeAttributes(doc, "a", "onclick");
        grabberUtils.removeAttributes(doc, "img", "srcset");
        grabberUtils.removeAttributes(doc, "img", "sizes");
		grabberUtils.saveImages(doc, Article.getArticleID(), Article.getFeedID());

		string html = "";
		doc->dump_memory_enc(out html);
        html = grabberUtils.postProcessing(ref html);
		Article.setHTML(html);
		delete doc;
	}

	private int ArticleSyncCount()
	{
		if(!useMaxArticles())
			return -1;

		return settings_general.get_int("max-articles");
	}

	public static void grabArticle(string url)
	{
		var grabber = new Grabber(url, null, null);
		if(grabber.process())
		{
			grabber.print();

			string html = grabber.getArticle();
			string title = Utils.UTF8fix(grabber.getTitle());
			string xml = "<?xml";

			while(html.has_prefix(xml))
			{
				int end = html.index_of_char('>');
				html = html.slice(end+1, html.length).chug();
			}

			string path = GLib.Environment.get_home_dir() + "/debug-article/%s.html".printf(title);

			if(FileUtils.test(path, GLib.FileTest.EXISTS))
				GLib.FileUtils.remove(path);

			var file = GLib.File.new_for_path(path);
			var stream = file.create(FileCreateFlags.REPLACE_DESTINATION);

			stream.write(html.data);
			logger.print(LogMessage.DEBUG, "Grabber: article html written to " + path);

			string output = libVilistextum.parse(html, 1);

			if(output == "" || output == null)
			{
				logger.print(LogMessage.ERROR, "could not generate preview text");
				return;
			}

			output = output.replace("\n"," ");
			output = output.replace("_"," ");

			path = GLib.Environment.get_home_dir() + "/debug-article/%s.txt".printf(title);

			if(FileUtils.test(path, GLib.FileTest.EXISTS))
				GLib.FileUtils.remove(path);

			file = GLib.File.new_for_path(path);
			stream = file.create(FileCreateFlags.REPLACE_DESTINATION);

			stream.write(output.data);
			logger.print(LogMessage.DEBUG, "Grabber: preview written to " + path);
		}
		else
		{
			logger.print(LogMessage.ERROR, "Grabber: article could not be processed " + url);
		}
	}

	public static void grabImages(string htmlFile, string url)
	{
		var html_cntx = new Html.ParserCtxt();
        html_cntx.use_options(Html.ParserOption.NOERROR + Html.ParserOption.NOWARNING);
        Html.Doc* doc = html_cntx.read_file(htmlFile);
        if (doc == null)
        {
            logger.print(LogMessage.DEBUG, "Grabber: parsing failed");
    		return;
    	}
		grabberUtils.repairURL("//img", "src", doc, url);
		grabberUtils.saveImages(doc, "", "");

		string html = "";
		doc->dump_memory_enc(out html);
        html = html.replace("<h3/>", "<h3></h3>");

    	int pos1 = html.index_of("<iframe", 0);
    	int pos2 = -1;
    	while(pos1 != -1)
    	{
    		pos2 = html.index_of("/>", pos1);
    		string broken_iframe = html.substring(pos1, pos2+2-pos1);
    		string fixed_iframe = broken_iframe.substring(0, broken_iframe.length) + "></iframe>";
    		html = html.replace(broken_iframe, fixed_iframe);
    		int pos3 = html.index_of("<iframe", pos1+7);
    		if(pos3 == pos1)
    			break;
    		else
    			pos1 = pos3;
    	}

		var file = GLib.File.new_for_path(GLib.Environment.get_home_dir() + "/debug-article/ArticleLocalImages.html");
		var stream = file.create(FileCreateFlags.REPLACE_DESTINATION);
		stream.write(html.data);
		delete doc;
	}

}
