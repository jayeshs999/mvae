#!/bin/bash

if [[ -z $1 ]]
then
	dir=logs
else
	dir=$1
fi

mkdir -p $dir

models=(
	#"e2,e2,e2"
	"p2,d2,e2"
	#"e2,h2,s2"
	#"h2,h2,h2"
	#"p6"
	#"s6"
	#"u6"
	"u2,u2,u2"
)

for dataset in bdp omniglot
do
for i in ${!models[@]}; do
    device=$(nvidia-smi -q -d Memory |grep -A4 GPU|grep Free | awk 'BEGIN{max=0} $3>max{max=$3;i=NR-1;} END{print i}')
	model=${models[$i]}
	fix_cur=False
	if [[ "$model" == *u* ]]
	then
		univ=True
	else
		univ=False
	fi
	curv_learn_delay=10
	echo $model, $fix_cur, $univ, $curv_learn_delay
	
	mkdir -p $dir/$dataset-$model-$fix_cur-$univ-$curv_learn_delay
	CUDA_VISIBLE_DEVICES=$device nohup python -m mt.examples.run \
		--dataset=$dataset \
		--model=$model \
		--fixed_curvature=$fix_cur \
		--universal=$univ \
		--scalar_parametrization=False \
		--epochs=200 \
		--curv_learn_delay $curv_learn_delay \
		--tb-dir "$dir/$dataset-$model-$fix_cur-$univ-$curv_learn_delay" > "$dir/$dataset-$model-$fix_cur-$univ-$curv_learn_delay/log.txt"&
	
	sleep 10
done
done