
world:
	cd elpi               && make
	cd equations          && make
	cd extlib             && make && make install    # required by SimpleIO
	cd simpleio           && make && make install    # required by QuickChick
	cd mathcomp           && make && make install    # required by QuickChick
	cd quickchick         && make

clean-slate:
	rm -rf */workdir
	rm -rf _build
