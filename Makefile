PKGS = elpi equations extlib simpleio mathcomp quickchick software-foundations \
	   hahn paco snu-sflib promising

CONTEXT = jscoq+64bit
ifeq ($(DUNE_WORKSPACE:%.wacoq=wacoq), wacoq)
CONTEXT = wacoq
endif

BUILT_PKGS = ${filter $(PKGS), ${notdir ${wildcard _build/$(CONTEXT)/*}}}

_V = ${firstword $(VERSION) $(VER)}

COMMIT_FLAGS = -a

ifneq ($(_V),)
MSG = [deploy] Prepare for $(_V).
else
MSG = ${error MSG= is mandatory}
endif

world:
	cd elpi               && make
	cd equations          && make
	cd extlib             && make && make install    # required by SimpleIO
	cd simpleio           && make && make install    # required by QuickChick
	cd mathcomp           && make && make install    # required by QuickChick
	cd quickchick         && make

set-ver:
	_scripts/set-ver 
commit-all:
	for d in $(PKGS); do ( cd $$d && git commit $(COMMIT_FLAGS) -m "$(MSG)" ); done
	git commit $(COMMIT_FLAGS) -m "$(MSG)"

push-all:
	for d in $(PKGS); do ( cd $$d && git push $(PUSH_FLAGS) ); done

commit+push-all:
	#for d in $(PKGS); do ( cd $$d && git commit $(COMMIT_FLAGS) -m "$(MSG)" && git push $(PUSH_FLAGS) ); done
	git commit $(COMMIT_FLAGS) -m "$(MSG)" && git push $(PUSH_FLAGS)

clean-slate:
	rm -rf */workdir
	rm -rf _build

pack:
	cd _build/$(CONTEXT) && npm pack ${addprefix ./, $(BUILT_PKGS)}
