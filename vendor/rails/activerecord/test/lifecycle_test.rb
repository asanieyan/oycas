require 'abstract_unit'
require 'fixtures/topic'
require 'fixtures/developer'
require 'fixtures/reply'

class Topic; def after_find() end end
class Developer; def after_find() end end
class SpecialDeveloper < Developer; end

class TopicManualObserver
  include Singleton

  attr_reader :action, :object, :callbacks

  def initialize
    Topic.add_observer(self)
    @callbacks = []
  end

  def update(callback_method, object)
    @callbacks << { "callback_method" => callback_method, "object" => object }
  end

  def has_been_notified?
    !@callbacks.empty?
  end
end

class TopicaObserver < ActiveRecord::Observer
  def self.observed_class() Topic end
  
  attr_reader :topic
  
  def after_find(topic)
    @topic = topic
  end
end

class TopicObserver < ActiveRecord::Observer
  attr_reader :topic
  
  def after_find(topic)
    @topic = topic
  end
end

class MultiObserver < ActiveRecord::Observer
  attr_reader :record
  
  def self.observed_class() [ Topic, Developer ] end

  def after_find(record)
    @record = record
  end

end

class LifecycleTest < Test::Unit::TestCase
  fixtures :topics, :developers

  def test_before_destroy
    assert_equal 2, Topic.count
    Topic.find(1).destroy
    assert_equal 0, Topic.count
  end
  
  def test_after_save
    ActiveRecord::Base.observers = :topic_manual_observer

    topic = Topic.find(1)
    topic.title = "hello"
    topic.save
    
    assert TopicManualObserver.instance.has_been_notified?
    assert_equal :after_save, TopicManualObserver.instance.callbacks.last["callback_method"]
  end
  
  def test_observer_update_on_save
    ActiveRecord::Base.observers = TopicManualObserver

    topic = Topic.find(1)    
    assert TopicManualObserver.instance.has_been_notified?
    assert_equal :after_find, TopicManualObserver.instance.callbacks.first["callback_method"]
  end
  
  def test_auto_observer
    topic_observer = TopicaObserver.instance

    topic = Topic.find(1)    
    assert_equal topic_observer.topic.title, topic.title
  end
  
  def test_infered_auto_observer
    topic_observer = TopicObserver.instance

    topic = Topic.find(1)    
    assert_equal topic_observer.topic.title, topic.title
  end
  
  def test_observing_two_classes
    multi_observer = MultiObserver.instance

    topic = Topic.find(1)
    assert_equal multi_observer.record.title, topic.title

    developer = Developer.find(1)    
    assert_equal multi_observer.record.name, developer.name
  end
  
  def test_observing_subclasses
    multi_observer = MultiObserver.instance

    developer = SpecialDeveloper.find(1)
    assert_equal multi_observer.record.name, developer.name
  end
end
