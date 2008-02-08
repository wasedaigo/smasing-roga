#! /usr/bin/env ruby

require 'gtk2'

# ���x���t���{�^���𖄂ߍ��񂾐V���� hbox �����D
# Gtk::HBox.new��Gtk::Box#pack_start�̈����͂��̃��\�b�h�̈����Ƃ��ēn�����D
def make_box(homogeneous, spacing, expand, fill, padding)
	box = Gtk::HBox.new(homogeneous, spacing)

	"Gtk::Box#pack_start (button, #{expand}, #{fill}, #{padding})".split(/ /).each do |s|
		button = Gtk::Button.new(s)
		box.pack_start(button, expand, fill, padding)
	end

	box
end

# �����̃`�F�b�N
# ruby foo.rb 1 �Ƃ����悤�Ƀv���O�����̈����Ƃ���1�`3�̐��l����͂���ƂR��ނ̃f����\������D
#
which = ARGV.shift
unless which
	$stderr.puts "usage: #{$0} num"
	$stderr.puts "	where num is 1, 2, or 3."
	exit 1
end

# �E�B���h�E���쐬�D
# main window �� "delete_event" ��ڑ�����̂��o���Ă������D
window = Gtk::Window.new
window.signal_connect("delete_event") do
	Gtk::main_quit
	false
end
window.border_width = 10

# make_box �ō쐬���鐅���{�b�N�X���p�b�N���邽�߂̐����{�b�N�X(VBox)��
# �쐬����D
# ���̐����{�b�N�X�ɁC�{�^���𖄂ߍ��񂾐����{�b�N�X��ςݏグ�Ă����D
box1 = Gtk::VBox.new(false, 0)

case which.to_i
when 1
	# �v���O�����̈�����1�̎��̃f��
	# ���x�����쐬����D
	# Gtk::Misc#set_alignment �ɂ��Ă̓E�B�W�F�b�g�̑����̃Z�N�V�����Ő�
	# ������D
	label = Gtk::Label.new("Gtk::HBox.new(false, 0)")
	label.set_alignment(0, 0)
	box1.pack_start(label, false, false, 0)

	# ������CGtk::HBox.new �� homegeneous�Cspacing�C
	# Gtk::HBox#pack_start �� expand�Cfill�Cpadding
	[
		[false, 0, false, false, 0],
		[false, 0, true,  false, 0],
		[false, 0, true,  true,  0],
	].each do |args|
		# �w�肳�ꂽ�����Ő����{�b�N�X���쐬���C�����{�b�N�X�ɏォ��p�b�N��
		# �Ă����D
		box2 = make_box(*args)
		box1.pack_start(box2, false, false, 0)
	end

	# Gtk::Separator �ɂ��Ă͌���D
	separator = Gtk::HSeparator.new
	box1.pack_start(separator, false, true, 5)


	# ��Ɠ��l�ł���D
	label = Gtk::Label.new("Gtk::HBox.new(true, 0)")
	label.set_alignment(0, 0)
	box1.pack_start(label, false, false, 0)

	[
		[true, 0, true, false, 0],
		[true, 0, true, true,  0],
	].each do |args|
		box2 = make_box(*args)
		box1.pack_start(box2, false, false, 0)
	end

	separator = Gtk::HSeparator.new
	box1.pack_start(separator, false, true, 5)

when 2
	# �v���O�����̈�����2�̎��̃f��
	label = Gtk::Label.new("Gtk::HBox.new(false, 10)")
	label.set_alignment(0, 0)
	box1.pack_start(label, false, false, 0)

	[
		[false, 10, true, false, 0],
		[false, 10, true, true,  0],
	].each do |args|
		box2 = make_box(*args)
		box1.pack_start(box2, false, false, 0)
	end

	separator = Gtk::HSeparator.new
	box1.pack_start(separator, false, true, 5)

	label = Gtk::Label.new("Gtk::HBox.new(false, 0)")
	label.set_alignment(0, 0)
	box1.pack_start(label, false, false, 0)

	[
		[false, 0, true, false, 10],
		[false, 0, true, true,  10],
	].each do |args|
		box2 = make_box(*args)
		box1.pack_start(box2, false, false, 0)
	end

	separator = Gtk::HSeparator.new
	box1.pack_start(separator, false, true, 5)

when 3
	# �v���O�����̈�����3�̎��̃f��
	# ����� Gtk::Box#pack_end ���g���ăE�B�W�F�b�g���E��������f���ł���D

	# �܂��ŏ��ɂ���܂ł̂悤�ɐV�����{�b�N�X���쐬����D
	box2 = make_box(false, 0, false, false, 0)

	# ���̃��x���͉E�[�Ɉʒu����D
	label = Gtk::Label.new("end")
	box2.pack_end(label, false, false, 0)
	box1.pack_start(box2, false, false, 0)

	# �����ł̓Z�p���[�^�̃T�C�Y�𖾎��I�� 400x5 �ɐݒ肷��D
	# �]���� make_box �ō쐬���������{�b�N�X�� 400 �s�N�Z�����ɂȂ�C"end" 
	# ���x���͂��̐����{�b�N�X���̑��̃��x���ƕ��������D
	# �Z�p���[�^�̃T�C�Y���w�肵�Ȃ������ꍇ�C���̐����{�b�N�X�̑S�ẴE�B
	# �W�F�b�g�͉\�Ȍ��薧�����ăp�b�N����Ă��܂��D
	separator = Gtk::HSeparator.new
	separator.set_size_request(400, 5)
	box1.pack_start(separator, false, true, 5)
end

# �I���{�^�����쐬���āC�V�ɍ쐬���������{�b�N�X�Ƀp�b�N����D
quitbox = Gtk::HBox.new(false, 0)
button = Gtk::Button.new("Quit")
button.signal_connect("clicked") do
	Gtk.main_quit
end 

quitbox.pack_start(button, true, false, 0)
box1.pack_start(quitbox, true, false, 0)
window.add(box1)

# ���ׂẴE�B�W�F�b�g��\������D
window.show_all

# �Ō�͓��R Gtk.main �ł���D
Gtk.main