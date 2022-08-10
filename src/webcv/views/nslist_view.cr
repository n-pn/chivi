require "./_base_view"
require "./chroot_view"

struct CV::NslistView
  include BaseView

  def initialize(@data : Nslist)
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "_base" { ChrootView.new(@data._base).to_json(jb) }
      jb.field "_user" { ChrootView.new(@data._user).to_json(jb) }

      jb.field "users" do
        jb.array do
          @data.users.each do |_user|
            ChrootView.new(_user).to_json(jb) unless _user.shield > 1
          end
        end
      end

      jb.field "other" do
        jb.array do
          @data.other.each do |other|
            ChrootView.new(other).to_json(jb) unless other.shield > 1
          end
        end
      end
    end
  end
end
