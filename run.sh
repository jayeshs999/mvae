dataset="omniglot"

models=(
	"e2,e2,e2"
	"p2,d2,e2"
	"p2,d2,e2"
)

fix_curs=(
	"False"
	"False"
	"True"
)

univs=(
	"False"
	"False"
	"False"
)

for i in ${!models[@]}; do
    device=$(nvidia-smi -q -d Memory |grep -A4 GPU|grep Free | awk 'BEGIN{max=0} $3>max{max=$3;i=NR-1;} END{print i}')
	model=${models[$i]}
	fix_cur=${fix_curs[$i]}
	univ=${univs[$i]}
	echo $model, $fix_cur, $univ

	CUDA_VISIBLE_DEVICES=$device nohup python -m mt.examples.run \
		--dataset=$dataset \
		--model=$model \
		--fixed_curvature=$fix_cur \
		--universal=$univ \
		--scalar_parametrization=False \
		--epochs=200 \
		2>&1 | tee "log/$dataset-$model-$fix_cur-$univ.txt" &
	
	sleep 10
done
