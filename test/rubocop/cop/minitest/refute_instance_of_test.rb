# frozen_string_literal: true

require 'test_helper'

class RefuteInstanceOfTest < Minitest::Test
  def setup
    @cop = RuboCop::Cop::Minitest::RefuteInstanceOf.new
  end

  def test_registers_offense_when_using_refute_with_instance_of
    assert_offense(<<~RUBY, @cop)
      class FooTest < Minitest::Test
        def test_do_something
          refute(object.instance_of?(SomeClass))
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `refute_instance_of(SomeClass, object)` over `refute(object.instance_of?(SomeClass))`.
        end
      end
    RUBY

    assert_correction(<<~RUBY, @cop)
      class FooTest < Minitest::Test
        def test_do_something
          refute_instance_of(SomeClass, object)
        end
      end
    RUBY
  end

  def test_registers_offense_when_using_refute_with_instance_of_and_message
    assert_offense(<<~RUBY, @cop)
      class FooTest < Minitest::Test
        def test_do_something
          refute(object.instance_of?(SomeClass), 'the message')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `refute_instance_of(SomeClass, object, 'the message')` over `refute(object.instance_of?(SomeClass), 'the message')`.
        end
      end
    RUBY

    assert_correction(<<~RUBY, @cop)
      class FooTest < Minitest::Test
        def test_do_something
          refute_instance_of(SomeClass, object, 'the message')
        end
      end
    RUBY
  end

  def refute_instance_of_method
    assert_no_offenses(<<~RUBY, @cop)
      class FooTest < Minitest::Test
        def test_do_something
          refute_instance_of(SomeClass, object)
        end
      end
    RUBY
  end
end
