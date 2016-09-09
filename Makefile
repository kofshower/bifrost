# Top level makefile, the real shit is at src/Makefile

default: all

CC=../../toolchain/gcc_only_4.8.1/bin/gcc

.DEFAULT:
	cd deps/lua/ && make clean && make linux && cd -
	cd deps/hiredis/ && make clean && make && cd -
	cd deps/linenoise/ && make clean && make && cd -
	cd src && $(MAKE) $@
	mkdir -p output output/tools output/bin output/conf output/log output/lib output/include
	cp script/redis_control.sh script/init.sh script/zk_getter src/redis-server src/redis-cli output/bin
	cp script/static.conf script/dynamic.conf script/cgroup.conf output/conf
	cp script/monitor.sh script/bgsave.sh script/bgrewrite.sh output/tools
	cp src/*.h output/include
	cp src/libae.a output/lib
	cp deps/hiredis/libhiredis.a output/lib
	cp ../utils/output/bin/get_servers ./output/bin
	wget -r -nH --preserve-permissions --level=0 --cut-dirs=6 ftp://getprod:getprod@product.scm.baidu.com:/data/prod-64/ps/se/galileo-monitor/galileo-monitor_1-0-5-1_PD_BL/output/so/libgalileomonitor.so

clean:
	cd src && $(MAKE) $@
	rm -rf output

install:
	cd src && $(MAKE) $@

.PHONY: install
