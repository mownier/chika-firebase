Pod::Spec.new do |s|
  s.name     = 'ChikaFirebase'
  s.version  = '0.3.1'
  s.summary  = 'Chika services implemented via Firebase'
  s.platform = :ios, '11.0'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage = 'https://github.com/mownier/chika-firebase'
  s.author   = { 'Mounir Ybanez' => 'rinuom91@gmail.com' }
  s.source   = { :git => 'https://github.com/mownier/chika-firebase.git', :tag => s.version.to_s }
  s.requires_arc = true  

  s.subspec 'Auth' do |ss|
    ss.dependency 'ChikaFirebase/Auth:AccessTokenRefresher'
    ss.dependency 'ChikaFirebase/Auth:EmailUpdater'
    ss.dependency 'ChikaFirebase/Auth:PasswordUpdater'
    ss.dependency 'ChikaFirebase/Auth:Registrar'
    ss.dependency 'ChikaFirebase/Auth:SignIn'
    ss.dependency 'ChikaFirebase/Auth:SignOut'
  end

  s.subspec 'Auth:AccessTokenRefresher' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Auth'
   
    ss.dependency 'ChikaFirebase/Validator:Auth'

    ss.source_files = 'ChikaFirebase/Source/Service/Auth/AccessTokenRefresher.swift'
  end

  s.subspec 'Auth:EmailUpdater' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Auth'
   
    ss.source_files = 'ChikaFirebase/Source/Service/Auth/EmailUpdater.swift'
  end

  s.subspec 'Auth:PasswordUpdater' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Auth'
   
    ss.source_files = 'ChikaFirebase/Source/Service/Auth/PasswordUpdater.swift'
  end

  s.subspec 'Auth:Registrar' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Auth'
   
    ss.dependency 'ChikaFirebase/Validator:Auth'

    ss.source_files = 'ChikaFirebase/Source/Service/Auth/Registrar.swift'
  end

  s.subspec 'Auth:SignIn' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Auth'
   
    ss.dependency 'ChikaFirebase/Validator:Auth'

    ss.source_files = 'ChikaFirebase/Source/Service/Auth/SignIn.swift'
  end

  s.subspec 'Auth:SignOut' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Auth'
   
    ss.source_files = 'ChikaFirebase/Source/Service/Auth/SignOut.swift'
  end

  s.subspec 'Query' do |ss|
    ss.dependency 'ChikaFirebase/Query:ChatMessage'
    ss.dependency 'ChikaFirebase/Query:Chat'
    ss.dependency 'ChikaFirebase/Query:Contact'
    ss.dependency 'ChikaFirebase/Query:Inbox'
    ss.dependency 'ChikaFirebase/Query:Message'
    ss.dependency 'ChikaFirebase/Query:MyInfo'
    ss.dependency 'ChikaFirebase/Query:Person'
    ss.dependency 'ChikaFirebase/Query:RecentChatMessage'
    ss.dependency 'ChikaFirebase/Query:ContactRequest'
    ss.dependency 'ChikaFirebase/Query:UnreadChatMessageCount'
    ss.dependency 'ChikaFirebase/Query:MessageSeenInfo'
  end

  s.subspec 'Query:ChatMessage' do |ss|
    ss.dependency 'FirebaseCommunity/Database'
    
    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Query'

    ss.dependency 'ChikaFirebase/Query:Message'
    
    ss.source_files = 'ChikaFirebase/Source/Service/Query/ChatMessageQuery.swift'
  end

  s.subspec 'Query:Chat' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'
    
    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Query'

    ss.dependency 'ChikaFirebase/Query:RecentChatMessage'
    
    ss.source_files = 'ChikaFirebase/Source/Service/Query/ChatQuery.swift'
  end

  s.subspec 'Query:Contact' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'
    
    ss.dependency 'ChikaCore/Service:Query'

    ss.dependency 'ChikaFirebase/Query:Chat'
    ss.dependency 'ChikaFirebase/Query:Person'
    
    ss.source_files = 'ChikaFirebase/Source/Service/Query/ContactQuery.swift'
  end

  s.subspec 'Query:Inbox' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'
    
    ss.dependency 'ChikaCore/Service:Query'

    ss.dependency 'ChikaFirebase/Query:Chat'
    
    ss.source_files = 'ChikaFirebase/Source/Service/Query/InboxQuery.swift'
  end

  s.subspec 'Query:Message' do |ss|
    ss.dependency 'FirebaseCommunity/Database'
    
    ss.dependency 'ChikaCore/Service:Query'

    ss.dependency 'ChikaFirebase/Query:Person'
    
    ss.source_files = 'ChikaFirebase/Source/Service/Query/MessageQuery.swift'
  end

  s.subspec 'Query:MyInfo' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Query'

    ss.dependency 'ChikaFirebase/Query:Person'
    
    ss.source_files = 'ChikaFirebase/Source/Service/Query/MyInfoQuery.swift'
  end

  s.subspec 'Query:Person' do |ss|
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Query'
    
    ss.source_files = 'ChikaFirebase/Source/Service/Query/PersonQuery.swift'
  end

  s.subspec 'Query:RecentChatMessage' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Query'

    ss.dependency 'ChikaFirebase/Query:Message'
    
    ss.source_files = 'ChikaFirebase/Source/Service/Query/RecentChatMessageQuery.swift'
  end

  s.subspec 'Query:ContactRequest' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Query'

    ss.dependency 'ChikaFirebase/Query:Person'
    
    ss.source_files = 'ChikaFirebase/Source/Service/Query/ContactRequestQuery.swift'
  end

  s.subspec 'Query:UnreadChatMessageCount' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Query'

    ss.dependency 'ChikaFirebase/Query:Person'
    
    ss.source_files = 'ChikaFirebase/Source/Service/Query/UnreadChatMessageCountQuery.swift'
  end

  s.subspec 'Query:MessageSeenInfo' do |ss|
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Query'

    ss.dependency 'ChikaFirebase/Query:Person'
    
    ss.source_files = 'ChikaFirebase/Source/Service/Query/MessageSeenInfoQuery.swift'
  end

  s.subspec 'Writer' do |ss|
    ss.dependency 'ChikaFirebase/Writer:AcceptContactRequestAction'
    ss.dependency 'ChikaFirebase/Writer:AddChatParticipantsAction'
    ss.dependency 'ChikaFirebase/Writer:ChatCreator'
    ss.dependency 'ChikaFirebase/Writer:ChatTitleUpdater'
    ss.dependency 'ChikaFirebase/Writer:ContactRequestSender'
    ss.dependency 'ChikaFirebase/Writer:DisplayNameUpdater'
    ss.dependency 'ChikaFirebase/Writer:IgnoreContactRequestAction'
    ss.dependency 'ChikaFirebase/Writer:MessageCreator'
    ss.dependency 'ChikaFirebase/Writer:NameUpdater'
    ss.dependency 'ChikaFirebase/Writer:OfflinePresenceSwitcher'
    ss.dependency 'ChikaFirebase/Writer:OnlinePresenceSwitcher'
    ss.dependency 'ChikaFirebase/Writer:PersonRegistrar'
    ss.dependency 'ChikaFirebase/Writer:TypingSwitcher'
    ss.dependency 'ChikaFirebase/Writer:SeenMessageMarker'
  end

  s.subspec 'Writer:AcceptContactRequestAction' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Writer'

    ss.source_files = 'ChikaFirebase/Source/Service/Writer/AcceptContactRequestAction.swift'
  end

  s.subspec 'Writer:AddChatParticipantsAction' do |ss|
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Writer'

    ss.source_files = 'ChikaFirebase/Source/Service/Writer/AddChatParticipantsAction.swift'
  end

  s.subspec 'Writer:ChatCreator' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Query'
    ss.dependency 'ChikaCore/Service:Writer'

    ss.dependency 'ChikaFirebase/Query:Chat'

    ss.source_files = 'ChikaFirebase/Source/Service/Writer/ChatCreator.swift'
  end

  s.subspec 'Writer:ChatTitleUpdater' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Writer'

    ss.source_files = 'ChikaFirebase/Source/Service/Writer/ChatTitleUpdater.swift'
  end

  s.subspec 'Writer:ContactRequestSender' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Writer'

    ss.source_files = 'ChikaFirebase/Source/Service/Writer/ContactRequestSender.swift'
  end

  s.subspec 'Writer:DisplayNameUpdater' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Writer'

    ss.source_files = 'ChikaFirebase/Source/Service/Writer/DisplayNameUpdater.swift'
  end

  s.subspec 'Writer:IgnoreContactRequestAction' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Writer'

    ss.source_files = 'ChikaFirebase/Source/Service/Writer/IgnoreContactRequestAction.swift'
  end

  s.subspec 'Writer:MessageCreator' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Query'
    ss.dependency 'ChikaCore/Service:Writer'

    ss.dependency 'ChikaFirebase/Query:Message'

    ss.source_files = 'ChikaFirebase/Source/Service/Writer/MessageCreator.swift'
  end

  s.subspec 'Writer:NameUpdater' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Writer'

    ss.source_files = 'ChikaFirebase/Source/Service/Writer/NameUpdater.swift'
  end

  s.subspec 'Writer:OfflinePresenceSwitcher' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Service:Writer'

    ss.source_files = 'ChikaFirebase/Source/Service/Writer/OfflinePresenceSwitcher.swift'
  end

  s.subspec 'Writer:OnlinePresenceSwitcher' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Writer'

    ss.source_files = 'ChikaFirebase/Source/Service/Writer/OnlinePresenceSwitcher.swift'
  end

  s.subspec 'Writer:PersonRegistrar' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Service:Writer'

    ss.source_files = 'ChikaFirebase/Source/Service/Writer/PersonRegistrar.swift'
  end

  s.subspec 'Writer:TypingSwitcher' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Writer'

    ss.source_files = 'ChikaFirebase/Source/Service/Writer/TypingSwitcher.swift'
  end

  s.subspec 'Writer:SeenMessageMarker' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Writer'

    ss.source_files = 'ChikaFirebase/Source/Service/Writer/SeenMessageMarker.swift'
  end

  s.subspec 'Listener' do |ss|
    ss.dependency 'ChikaFirebase/Listener:AddedContact'
    ss.dependency 'ChikaFirebase/Listener:AddedIntoChat'
    ss.dependency 'ChikaFirebase/Listener:ChatTitleUpdate'
    ss.dependency 'ChikaFirebase/Listener:Presence'
    ss.dependency 'ChikaFirebase/Listener:ReceivedContactRequest'
    ss.dependency 'ChikaFirebase/Listener:RecentChatMessage'
    ss.dependency 'ChikaFirebase/Listener:TypingStatus'
    ss.dependency 'ChikaFirebase/Listener:ChatParticipantPresence'
    ss.dependency 'ChikaFirebase/Listener:SeenMessage'
  end

  s.subspec 'Listener:AddedContact' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Query'
    ss.dependency 'ChikaCore/Service:Listener'

    ss.dependency 'ChikaFirebase/Query:Chat'
    ss.dependency 'ChikaFirebase/Query:Person'

    ss.source_files = 'ChikaFirebase/Source/Service/Listener/AddedContactListener.swift'
  end

  s.subspec 'Listener:AddedIntoChat' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Query'
    ss.dependency 'ChikaCore/Service:Listener'

    ss.dependency 'ChikaFirebase/Query:Chat'

    ss.source_files = 'ChikaFirebase/Source/Service/Listener/AddedIntoChatListener.swift'
  end

  s.subspec 'Listener:ChatTitleUpdate' do |ss|
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Listener'

    ss.source_files = 'ChikaFirebase/Source/Service/Listener/ChatTitleUpdateListener.swift'
  end

  s.subspec 'Listener:Presence' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Listener'

    ss.source_files = 'ChikaFirebase/Source/Service/Listener/PresenceListener.swift'
  end

  s.subspec 'Listener:ReceivedContactRequest' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Listener'
    ss.dependency 'ChikaCore/Service:Query'

    ss.dependency 'ChikaFirebase/Query:Person'

    ss.source_files = 'ChikaFirebase/Source/Service/Listener/ReceivedContactRequestListener.swift'
  end

  s.subspec 'Listener:RecentChatMessage' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Listener'
    ss.dependency 'ChikaCore/Service:Query'

    ss.dependency 'ChikaFirebase/Query:Chat'

    ss.source_files = 'ChikaFirebase/Source/Service/Listener/RecentChatMessageListener.swift'
  end

  s.subspec 'Listener:TypingStatus' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Listener'
    ss.dependency 'ChikaCore/Service:Query'

    ss.dependency 'ChikaFirebase/Query:Person'

    ss.source_files = 'ChikaFirebase/Source/Service/Listener/TypingStatusListener.swift'
  end

  s.subspec 'Listener:ChatParticipantPresence' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Listener'

    ss.source_files = 'ChikaFirebase/Source/Service/Listener/ChatParticipantPresenceListener.swift'
  end

  s.subspec 'Listener:SeenMessage' do |ss|
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Listener'

    ss.dependency 'ChikaFirebase/Query:Person'

    ss.source_files = 'ChikaFirebase/Source/Service/Listener/SeenMessageListener.swift'
  end

  s.subspec 'Search' do |ss|
    ss.dependency 'ChikaFirebase/Search:Person'
  end
  
  s.subspec 'Search:Person' do |ss|
    ss.dependency 'FirebaseCommunity/Auth'
    ss.dependency 'FirebaseCommunity/Database'

    ss.dependency 'ChikaCore/Error'
    ss.dependency 'ChikaCore/Service:Query'
    ss.dependency 'ChikaCore/Service:Search'

    ss.dependency 'ChikaFirebase/Query:Chat'
    ss.dependency 'ChikaFirebase/Query:Person'

    ss.dependency 'TNExtensions/EmailValidator'

    ss.source_files = 'ChikaFirebase/Source/Service/Search/PersonSearch.swift'
  end

  s.subspec 'Validator' do |ss|
    ss.dependency 'ChikaFirebase/Validator:Auth'
  end

  s.subspec 'Validator:Auth' do |ss|
    ss.source_files = 'ChikaFirebase/Source/Validator/AuthValidator.swift'
  end

end
