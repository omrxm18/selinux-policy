CHECK_MODULE=checkmodule
SEMODULE_PACKAGE=semodule_package
SEMODULE=semodule

OUT_DIR=out
MODS_DIR=mods
SRC_DIR=rules

PP_FILES=$(patsubst $(SRC_DIR)/%.te,%.pp,$(wildcard $(SRC_DIR)/*.te))

%.pp: $(SRC_DIR)/%.te
	@mkdir -p $(MODS_DIR)
	@mkdir -p $(OUT_DIR)
	@$(CHECK_MODULE) -m $< -o $(MODS_DIR)/$*.mod
	@$(SEMODULE_PACKAGE) -o $(OUT_DIR)/$@ -m $(MODS_DIR)/$*.mod

.PHONY: all help install remove clean

all: $(PP_FILES) install

help:
	@echo "make <name>                            build policy pp to out/<name>.pp"
	@echo "install MODULE=<name without .pp>      load the targeted policy"
	@echo "remove  MODULE=<name wihtout .pp>      unload the targeted policy"
	@echo "clean                                  clean artifacts"

install: $(if $(MODULE),$(OUT_DIR)/$(MODULE).pp,$(addprefix $(OUT_DIR)/,$(PP_FILES)))
	sudo $(SEMODULE) -i $^

remove:
	sudo $(SEMODULE) -r $@

clean:
	rm -rf $(OUT_DIR) $(MODS_DIR)