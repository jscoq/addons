PKGS = elpi equations extlib simpleio mathcomp quickchick software-foundations \
	   hahn paco snu-sflib promising

CONTEXT = jscoq+64bit
ifeq ($(DUNE_WORKSPACE:%.wacoq=wacoq), wacoq)
CONTEXT = wacoq
endif

BUILT_PKGS = ${filter $(PKGS), ${notdir ${wildcard _build/$(CONTEXT)/*}}}

COMMIT_FLAGS = -a

world:
	cd elpi               && make
	cd equations          && make
	cd extlib             && make && make install    # required by SimpleIO
	cd simpleio           && make && make install    # required by QuickChick
	cd mathcomp           && make && make install    # required by QuickChick
	cd quickchick         && make

set-ver:
	_scripts/set-ver ${firstword $(VERSION) $(VER)}

commit-all:
	for d in $(PKGS); do ( cd $$d && git commit $(COMMIT_FLAGS) -m "$(MSG)" ); done

push-all:
	for d in $(PKGS); do cd $$d && git push $(PUSH_FLAGS); done

clean-slate:
	rm -rf */workdir
	rm -rf _build

pack:
	cd _build/$(CONTEXT) && npm pack ${addprefix ./, $(BUILT_PKGS)}
