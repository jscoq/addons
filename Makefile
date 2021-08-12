PKGS = elpi equations extlib simpleio mathcomp mathcomp-extra quickchick software-foundations \
	   hahn paco snu-sflib promising fcsl-pcm htt pnp

CONTEXT = jscoq+32bit
ifeq ($(DUNE_WORKSPACE:%.64=64), 64)
CONTEXT = jscoq+64bit
endif
ifeq ($(DUNE_WORKSPACE:%.wacoq=wacoq), wacoq)
CONTEXT = wacoq
endif

# needed when invoking `opam install`
OPAMSWITCH = $(CONTEXT)
export OPAMSWITCH

ifeq ($(DUNE_WORKSPACE),)
ifeq ($(CONTEXT), wacoq)
DUNE_WORKSPACE = $(PWD)/dune-workspace.wacoq
endif
ifeq ($(CONTEXT), jscoq+64bit)
DUNE_WORKSPACE = $(PWD)/dune-workspace.64
endif
endif

ifneq ($(DUNE_WORKSPACE),)
export DUNE_WORKSPACE
endif

OPAM_ENV = eval `opam env`

BUILT_PKGS = ${filter $(PKGS), ${notdir ${wildcard _build/$(CONTEXT)/*}}}

_V = ${firstword $(VERSION) $(VER) $(V)}

COMMIT_FLAGS = -a

ifneq ($(_V),)
MSG = [deploy] Prepare for $(_V).
else
ifeq ($(CONTEXT), wacoq)
_V = ${shell wacoq --version}
else
_V = ${shell jscoq --version}
endif
MSG = ${error MSG= is mandatory}
endif

world:
	cd elpi               && make
	cd equations          && make
	cd extlib             && make && make install    # required by SimpleIO
	cd simpleio           && make && make install    # required by QuickChick
	cd mathcomp           && make && make install    # required by QuickChick, FCSL-PCM, HTT
	cd mathcomp-extra     && make
	cd quickchick         && make
	cd hahn               && make && make install    # required by Promising
	cd paco               && make && make install    # required by Promising
	cd snu-sflib          && make && make install    # required by Promising
	cd promising          && make
	cd fcsl-pcm           && make && make install    # required by HTT
	cd htt                && make && make install    # required by PnP
	cd pnp                && make
ifneq ($(filter software-foundations, $(WITH_PRIVATE)),)
	cd software-foundations && make
endif

privates:
ifneq ($(filter software-foundations, $(WITH_PRIVATE)),)
	cd software-foundations && make
endif

set-ver:
	_scripts/set-ver ${addprefix @,$(CONTEXT)} $(_V)
	if [ -e _build/$(CONTEXT) ] ; then \
	  $(OPAM_ENV) && dune build _build/$(CONTEXT)/*/package.json ; fi  # update build directory as well

pack:
	rm -rf _build/$(CONTEXT)/*.tgz
	cd _build/$(CONTEXT) && npm pack ${addprefix ./, $(BUILT_PKGS)}

commit-all:
	for d in $(PKGS); do ( cd $$d && git commit $(COMMIT_FLAGS) -m "$(MSG)" ); done
	git commit $(COMMIT_FLAGS) -m "$(MSG)"

push-all:
	for d in $(PKGS); do ( cd $$d && git push $(PUSH_FLAGS) ); done

commit+push-all:
	for d in $(PKGS); do ( cd $$d && \
	   	git commit $(COMMIT_FLAGS) -m "$(MSG)" && \
	    git push $(PUSH_FLAGS) ); done
	git commit $(COMMIT_FLAGS) -m "$(MSG)" && git push $(PUSH_FLAGS)

clean-slate:
	rm -rf */workdir
	rm -rf _build

ci:
	$(MAKE) clean-slate
	$(OPAM_ENV) && $(MAKE)
	$(MAKE) set-ver
	$(MAKE) pack
