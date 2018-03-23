

xfce4:
	./makefile.sh xfce4
cinnamon:
	./makefile.sh cinnamon
gnome:
	./makefile.sh gnome
i3:
	./makefile.sh i3
lxde:
	./makefile.sh lxde
aur:
	./aur_controller.sh build
clean:
	sudo rm -r ./work
