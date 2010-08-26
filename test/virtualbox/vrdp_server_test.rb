require File.expand_path("../../test_helper", __FILE__)

class VRDPServerTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::VRDPServer
    @interface = mock("interface")
    @parent = mock("parent")
  end

  context "class methods" do
    context "populating relationship" do
      setup do
        @instance = mock("instance")
        @klass.stubs(:new).returns(@instance)

        @vrdp_server = mock("vrdp_server")
        @interface.stubs(:vrdp_server).returns(@vrdp_server)
      end

      should "call new for the interface" do
        @klass.expects(:new).with(nil, @vrdp_server).once.returns(@instance)
        assert_equal @instance, @klass.populate_relationship(nil, @interface)
      end
    end

    context "saving relationship" do
      should "call save with the interface on the instance" do
        instance = mock("instance")
        instance.expects(:save).once

        @klass.save_relationship(nil, instance)
      end
    end
  end

  context "initializing" do
    setup do
      @klass.any_instance.stubs(:load_interface_attributes)
    end

    should "load interface attribtues" do
      @klass.any_instance.expects(:load_interface_attributes).with(@interface).once
      @klass.new(@parent, @interface)
    end

    should "not be dirty" do
      @instance = @klass.new(@parent, @interface)
      assert !@instance.changed?
    end

    should "be existing record" do
      @instance = @klass.new(@parent, @interface)
      assert !@instance.new_record?
    end
  end

  context "instance methods" do
    setup do
      @klass.any_instance.stubs(:load_interface_attributes)

      @parent = mock("parent")
      @interface = mock("interface")
      @instance = @klass.new(@parent, @interface)
    end

    context "saving" do
      setup do
        @vrdp_server = mock("vrdp_server")
        @session = mock("session")
        @machine = mock("machine")
        @machine.stubs(:vrdp_server).returns(@vrdp_server)
        @session.stubs(:machine).returns(@machine)
        @parent.stubs(:with_open_session).yields(@session)
      end

      should "save the interface settings with the new bios settings" do
        save_seq = sequence("save_seq")
        @instance.expects(:save_changed_interface_attributes).with(@vrdp_server).once.in_sequence(save_seq)
        @instance.save
      end
    end
  end
end
