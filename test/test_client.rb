require "graphql"
require "graphql/client"
require "json"
require "minitest/autorun"

class TestClient < MiniTest::Test
  UserType = GraphQL::ObjectType.define do
    name "User"
    field :id, !types.ID
    field :firstName, !types.String
    field :lastName, !types.String
  end

  QueryType = GraphQL::ObjectType.define do
    name "Query"
    field :viewer, UserType
  end

  Schema = GraphQL::Schema.new(query: QueryType)

  module Temp
  end

  def setup
    @client = GraphQL::Client.new(schema: Schema)
  end

  def teardown
    Temp.constants.each do |sym|
      Temp.send(:remove_const, sym)
    end
  end

  def test_client_parse_anonymous_operation
    Temp.const_set :UserQuery, @client.parse(<<-'GRAPHQL')
      {
        viewer {
          id
          firstName
          lastName
        }
      }
    GRAPHQL

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, @client.document.to_query_string)
      query TestClient__Temp__UserQuery {
        viewer {
          id
          firstName
          lastName
        }
      }
    GRAPHQL

    assert_equal "TestClient__Temp__UserQuery", Temp::UserQuery.operation_name

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, Temp::UserQuery.document.to_query_string)
      query TestClient__Temp__UserQuery {
        viewer {
          id
          firstName
          lastName
        }
      }
    GRAPHQL

    @client.validate!
  end

  def test_client_parse_anonymous_query
    Temp.const_set :UserQuery, @client.parse(<<-'GRAPHQL')
      query {
        viewer {
          id
          firstName
          lastName
        }
      }
    GRAPHQL

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, @client.document.to_query_string)
      query TestClient__Temp__UserQuery {
        viewer {
          id
          firstName
          lastName
        }
      }
    GRAPHQL

    assert_equal "TestClient__Temp__UserQuery", Temp::UserQuery.operation_name

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, Temp::UserQuery.document.to_query_string)
      query TestClient__Temp__UserQuery {
        viewer {
          id
          firstName
          lastName
        }
      }
    GRAPHQL

    @client.validate!
  end

  def test_client_parse_query_document
    Temp.const_set :UserDocument, @client.parse(<<-'GRAPHQL')
      query getUser {
        viewer {
          id
          firstName
          lastName
        }
      }
    GRAPHQL

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, @client.document.to_query_string)
      query TestClient__Temp__UserDocument__getUser {
        viewer {
          id
          firstName
          lastName
        }
      }
    GRAPHQL

    assert_equal "TestClient__Temp__UserDocument__getUser", Temp::UserDocument.operation_name

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, Temp::UserDocument.document.to_query_string)
      query TestClient__Temp__UserDocument__getUser {
        viewer {
          id
          firstName
          lastName
        }
      }
    GRAPHQL

    @client.validate!
  end

  def test_client_parse_anonymous_mutation
    Temp.const_set :LikeMutation, @client.parse(<<-'GRAPHQL')
      mutation {
        likeStory(storyID: 12345) {
          story {
            likeCount
          }
        }
      }
    GRAPHQL

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, @client.document.to_query_string)
      mutation TestClient__Temp__LikeMutation {
        likeStory(storyID: 12345) {
          story {
            likeCount
          }
        }
      }
    GRAPHQL

    assert_equal "TestClient__Temp__LikeMutation", Temp::LikeMutation.operation_name

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, Temp::LikeMutation.document.to_query_string)
      mutation TestClient__Temp__LikeMutation {
        likeStory(storyID: 12345) {
          story {
            likeCount
          }
        }
      }
    GRAPHQL
  end

  def test_client_parse_mutation_document
    Temp.const_set :LikeDocument, @client.parse(<<-'GRAPHQL')
      mutation likeStory {
        likeStory(storyID: 12345) {
          story {
            likeCount
          }
        }
      }
    GRAPHQL

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, @client.document.to_query_string)
      mutation TestClient__Temp__LikeDocument__likeStory {
        likeStory(storyID: 12345) {
          story {
            likeCount
          }
        }
      }
    GRAPHQL

    assert_equal "TestClient__Temp__LikeDocument__likeStory", Temp::LikeDocument.operation_name

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, Temp::LikeDocument.document.to_query_string)
      mutation TestClient__Temp__LikeDocument__likeStory {
        likeStory(storyID: 12345) {
          story {
            likeCount
          }
        }
      }
    GRAPHQL
  end

  def test_client_parse_anonymous_fragment
    Temp.const_set :UserFragment, @client.parse(<<-'GRAPHQL')
      fragment on User {
        id
        firstName
        lastName
      }
    GRAPHQL

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, @client.document.to_query_string)
      fragment TestClient__Temp__UserFragment on User {
        id
        firstName
        lastName
      }
    GRAPHQL

    assert_equal nil, Temp::UserFragment.operation_name

    user = Temp::UserFragment.new({"id" => 1, "firstName" => "Joshua", "lastName" => "Peek"})
    assert_equal 1, user.id
    assert_equal "Joshua", user.first_name
    assert_equal "Peek", user.last_name

    assert_raises GraphQL::Client::ValidationError do
      begin
        @client.validate!
      rescue GraphQL::Client::ValidationError => e
        assert_equal "Fragment TestClient__Temp__UserFragment was defined, but not used", e.message
        raise e
      end
    end
  end

  def test_client_parse_fragment_document
    Temp.const_set :UserDocument, @client.parse(<<-'GRAPHQL')
      fragment userProfile on User {
        id
        firstName
        lastName
      }
    GRAPHQL

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, @client.document.to_query_string)
      fragment TestClient__Temp__UserDocument__userProfile on User {
        id
        firstName
        lastName
      }
    GRAPHQL

    assert_equal nil, Temp::UserDocument.operation_name
  end

  def test_client_parse_query_fragment_document
    Temp.const_set :UserDocument, @client.parse(<<-'GRAPHQL')
      query withNestedFragments {
        user(id: 4) {
          friends(first: 10) {
            ...friendFields
          }
          mutualFriends(first: 10) {
            ...friendFields
          }
        }
      }

      fragment friendFields on User {
        id
        name
        ...standardProfilePic
      }

      fragment standardProfilePic on User {
        profilePic(size: 50)
      }
    GRAPHQL

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, @client.document.to_query_string)
      query TestClient__Temp__UserDocument__withNestedFragments {
        user(id: 4) {
          friends(first: 10) {
            ... TestClient__Temp__UserDocument__friendFields
          }
          mutualFriends(first: 10) {
            ... TestClient__Temp__UserDocument__friendFields
          }
        }
      }

      fragment TestClient__Temp__UserDocument__friendFields on User {
        id
        name
        ... TestClient__Temp__UserDocument__standardProfilePic
      }

      fragment TestClient__Temp__UserDocument__standardProfilePic on User {
        profilePic(size: 50)
      }
    GRAPHQL

    assert_equal "TestClient__Temp__UserDocument__withNestedFragments", Temp::UserDocument.operation_name

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, Temp::UserDocument.document.to_query_string)
      query TestClient__Temp__UserDocument__withNestedFragments {
        user(id: 4) {
          friends(first: 10) {
            ... TestClient__Temp__UserDocument__friendFields
          }
          mutualFriends(first: 10) {
            ... TestClient__Temp__UserDocument__friendFields
          }
        }
      }

      fragment TestClient__Temp__UserDocument__friendFields on User {
        id
        name
        ... TestClient__Temp__UserDocument__standardProfilePic
      }

      fragment TestClient__Temp__UserDocument__standardProfilePic on User {
        profilePic(size: 50)
      }
    GRAPHQL
  end

  def test_client_parse_query_external_fragments_document
    Temp.const_set :ProfilePictureFragment, @client.parse(<<-'GRAPHQL')
      fragment on User {
        profilePic(size: 50)
      }
    GRAPHQL

    Temp.const_set :FriendFragment, @client.parse(<<-'GRAPHQL')
      fragment on User {
        id
        name
        ...TestClient::Temp::ProfilePictureFragment
      }
    GRAPHQL

    Temp.const_set :UserQuery, @client.parse(<<-'GRAPHQL')
      query {
        user(id: 4) {
          friends(first: 10) {
            ...TestClient::Temp::FriendFragment
          }
          mutualFriends(first: 10) {
            ...TestClient::Temp::FriendFragment
          }
        }
      }
    GRAPHQL

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, @client.document.to_query_string)
      fragment TestClient__Temp__ProfilePictureFragment on User {
        profilePic(size: 50)
      }

      fragment TestClient__Temp__FriendFragment on User {
        id
        name
        ... TestClient__Temp__ProfilePictureFragment
      }

      query TestClient__Temp__UserQuery {
        user(id: 4) {
          friends(first: 10) {
            ... TestClient__Temp__FriendFragment
          }
          mutualFriends(first: 10) {
            ... TestClient__Temp__FriendFragment
          }
        }
      }
    GRAPHQL

    assert_equal "TestClient__Temp__UserQuery", Temp::UserQuery.operation_name
    assert_equal nil, Temp::FriendFragment.operation_name
    assert_equal nil, Temp::ProfilePictureFragment.operation_name

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, Temp::UserQuery.document.to_query_string)
      query TestClient__Temp__UserQuery {
        user(id: 4) {
          friends(first: 10) {
            ... TestClient__Temp__FriendFragment
          }
          mutualFriends(first: 10) {
            ... TestClient__Temp__FriendFragment
          }
        }
      }

      fragment TestClient__Temp__ProfilePictureFragment on User {
        profilePic(size: 50)
      }

      fragment TestClient__Temp__FriendFragment on User {
        id
        name
        ... TestClient__Temp__ProfilePictureFragment
      }
    GRAPHQL
  end

  def test_client_parse_query_external_document_fragment
    Temp.const_set :ProfileFragments, @client.parse(<<-'GRAPHQL')
      fragment profilePic on User {
        profilePic(size: 50)
      }

      fragment friendFields on User {
        id
        name
        ...profilePic
      }
    GRAPHQL

    Temp.const_set :UserQuery, @client.parse(<<-'GRAPHQL')
      query {
        user(id: 4) {
          friends(first: 10) {
            ...TestClient::Temp::ProfileFragments.friendFields
          }
          mutualFriends(first: 10) {
            ...TestClient::Temp::ProfileFragments.friendFields
          }
        }
      }
    GRAPHQL

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, @client.document.to_query_string)
      fragment TestClient__Temp__ProfileFragments__profilePic on User {
        profilePic(size: 50)
      }

      fragment TestClient__Temp__ProfileFragments__friendFields on User {
        id
        name
        ... TestClient__Temp__ProfileFragments__profilePic
      }

      query TestClient__Temp__UserQuery {
        user(id: 4) {
          friends(first: 10) {
            ... TestClient__Temp__ProfileFragments__friendFields
          }
          mutualFriends(first: 10) {
            ... TestClient__Temp__ProfileFragments__friendFields
          }
        }
      }
    GRAPHQL

    assert_equal "TestClient__Temp__UserQuery", Temp::UserQuery.operation_name
    assert_equal nil, Temp::ProfileFragments.operation_name

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, Temp::UserQuery.document.to_query_string)
      query TestClient__Temp__UserQuery {
        user(id: 4) {
          friends(first: 10) {
            ... TestClient__Temp__ProfileFragments__friendFields
          }
          mutualFriends(first: 10) {
            ... TestClient__Temp__ProfileFragments__friendFields
          }
        }
      }

      fragment TestClient__Temp__ProfileFragments__profilePic on User {
        profilePic(size: 50)
      }

      fragment TestClient__Temp__ProfileFragments__friendFields on User {
        id
        name
        ... TestClient__Temp__ProfileFragments__profilePic
      }
    GRAPHQL
  end

  def test_client_parse_multiple_queries
    Temp.const_set :FriendFragment, @client.parse(<<-'GRAPHQL')
      fragment on User {
        id
        name
      }
    GRAPHQL

    Temp.const_set :FriendsQuery, @client.parse(<<-'GRAPHQL')
      query {
        user(id: 4) {
          friends(first: 10) {
            ...TestClient::Temp::FriendFragment
          }
        }
      }
    GRAPHQL

    Temp.const_set :MutualFriendsQuery, @client.parse(<<-'GRAPHQL')
      query {
        user(id: 4) {
          mutualFriends(first: 10) {
            ...TestClient::Temp::FriendFragment
          }
        }
      }
    GRAPHQL

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, @client.document.to_query_string)
      fragment TestClient__Temp__FriendFragment on User {
        id
        name
      }

      query TestClient__Temp__FriendsQuery {
        user(id: 4) {
          friends(first: 10) {
            ... TestClient__Temp__FriendFragment
          }
        }
      }

      query TestClient__Temp__MutualFriendsQuery {
        user(id: 4) {
          mutualFriends(first: 10) {
            ... TestClient__Temp__FriendFragment
          }
        }
      }
    GRAPHQL

    assert_equal nil, Temp::FriendFragment.operation_name
    assert_equal "TestClient__Temp__FriendsQuery", Temp::FriendsQuery.operation_name
    assert_equal "TestClient__Temp__MutualFriendsQuery", Temp::MutualFriendsQuery.operation_name

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, Temp::FriendsQuery.document.to_query_string)
      query TestClient__Temp__FriendsQuery {
        user(id: 4) {
          friends(first: 10) {
            ... TestClient__Temp__FriendFragment
          }
        }
      }

      fragment TestClient__Temp__FriendFragment on User {
        id
        name
      }
    GRAPHQL

    assert_equal(<<-'GRAPHQL'.gsub(/^      /, "").chomp, Temp::MutualFriendsQuery.document.to_query_string)
      query TestClient__Temp__MutualFriendsQuery {
        user(id: 4) {
          mutualFriends(first: 10) {
            ... TestClient__Temp__FriendFragment
          }
        }
      }

      fragment TestClient__Temp__FriendFragment on User {
        id
        name
      }
    GRAPHQL
  end

  def test_client_parse_fragment_query_result_aliases
    Temp.const_set :UserFragment, @client.parse(<<-'GRAPHQL')
      fragment on User {
        login_url
        profileName
        name: profileName
        isCool
      }
    GRAPHQL

    user = Temp::UserFragment.new({"__typename" => "User", "login_url" => "/login", "profileName" => "Josh", "name" => "Josh", "isCool" => true})
    assert_equal "/login", user.login_url
    assert_equal "Josh", user.profile_name
    assert_equal "Josh", user.name
    assert user.is_cool?
  end

  def test_client_parse_fragment_query_result_with_nested_fields
    Temp.const_set :UserFragment, @client.parse(<<-'GRAPHQL')
      fragment on User {
        id
        repositories {
          name
          watchers {
            login
          }
        }
      }
    GRAPHQL

    user = Temp::UserFragment.new({
      "id" => "1",
      "repositories" => [
        {
          "name" => "github",
          "watchers" => {
            "login" => "josh"
          }
        }
      ]
    })

    assert_equal "1", user.id
    assert_kind_of Array, user.repositories
    assert_equal "github", user.repositories[0].name
    assert_equal "josh", user.repositories[0].watchers.login
  end

  def test_client_parse_fragment_query_result_with_inline_fragments
    Temp.const_set :UserFragment, @client.parse(<<-'GRAPHQL')
      fragment on User {
        id
        repositories {
          ... on Repository {
            name
            watchers {
              ... on User {
                login
              }
            }
          }
        }
      }
    GRAPHQL

    user = Temp::UserFragment.new({
      "id" => "1",
      "repositories" => [
        {
          "name" => "github",
          "watchers" => {
            "login" => "josh"
          }
        }
      ]
    })

    assert_equal "1", user.id
    assert_kind_of Array, user.repositories
    assert_equal "github", user.repositories[0].name
    assert_equal "josh", user.repositories[0].watchers.login
  end

  def test_client_parse_nested_inline_fragments_on_same_node
    Temp.const_set :UserFragment, @client.parse(<<-'GRAPHQL')
      fragment on Node {
        id
        ... on User {
          login
          ... on AdminUser {
            password
          }
        }
        ... on Organization {
          name
        }
      }
    GRAPHQL

    user = Temp::UserFragment.new({
      "__typename" => "User",
      "id" => "1",
      "login" => "josh",
      "password" => "secret"
    })

    assert_equal "1", user.id
    assert_equal "josh", user.login
    assert_equal "secret", user.password
  end

  def test_client_parse_fragment_spread_constant
    Temp.const_set :UserFragment, @client.parse(<<-'GRAPHQL')
      fragment on User {
        login
      }
    GRAPHQL

    Temp.const_set :RepositoryFragment, @client.parse(<<-'GRAPHQL')
      fragment on Repository {
        name
        owner {
          ...TestClient::Temp::UserFragment
        }
      }
    GRAPHQL

    repo = Temp::RepositoryFragment.new({
      "__typename" => "Repository",
      "name" => "rails",
      "owner" => {
        "__typename" => "User",
        "login" => "josh"
      }
    })
    assert_equal "rails", repo.name
    refute repo.owner.respond_to?(:login)

    owner = Temp::UserFragment.new(repo.owner)
    assert_equal "josh", owner.login
  end

  def test_client_parse_invalid_fragment_cast
    Temp.const_set :UserFragment, @client.parse(<<-'GRAPHQL')
      fragment on User {
        login
      }
    GRAPHQL

    Temp.const_set :RepositoryFragment, @client.parse(<<-'GRAPHQL')
      fragment on Repository {
        name
        owner {
          login
        }
      }
    GRAPHQL

    repo = Temp::RepositoryFragment.new({
      "__typename" => "Repository",
      "name" => "rails",
      "owner" => {
        "__typename" => "User",
        "login" => "josh"
      }
    })
    assert_equal "rails", repo.name
    assert_equal "josh", repo.owner.login

    assert_raises TypeError do
      Temp::UserFragment.new(repo.owner)
    end
  end
end