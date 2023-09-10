.PHONY: all
all : build test

build:
	@+$(MAKE) -C control-reg init elab
	@+$(MAKE) -C spi-cpu-interface init elab	
	@+$(MAKE) -C homecockpit init elab
	@+$(MAKE) -C input init elab
	@+$(MAKE) -C output init elab
	@+$(MAKE) -C status-reg init elab

test:
	@+$(MAKE) --no-print-directory -C control-reg run
	@+$(MAKE) --no-print-directory -C spi-cpu-interface run
	@+$(MAKE) --no-print-directory -C homecockpit run
	@+$(MAKE) --no-print-directory -C input run
	@+$(MAKE) --no-print-directory -C output run
	@+$(MAKE) --no-print-directory -C status-reg run

clean:
	@+$(MAKE) -C control-reg clean
	@+$(MAKE) -C spi-cpu-interface clean
	@+$(MAKE) -C homecockpit clean
	@+$(MAKE) -C input clean
	@+$(MAKE) -C output clean
	@+$(MAKE) -C status-reg clean
