tag filters
	prop abilities = ["On Reveal", "Ongoing", "Discard", "Move", "Destroy", "No Ability", "Others"]
	prop energyValues = ['0', '1', '2', '3', '4', '5', '6+']
	prop powerValues = ['1-', '2', '3', '4', '5', '6+']
	prop selectedAbility = ""
	prop selectedEnergy = ""
	prop selectedPower = ""
	prop selectedSeries = ""
	
	css .filter fs:sm d:flex fw:700 jc:center ai:center
		label ta:center
		span tt:uppercase c:lightcyan
		#card-ability bgc:green5
		#card-energy bgc:blue5 w:70px
		#card-power bgc:orange4 w:60px
		#card-series bgc:purple4
		select c:#010b13
		option fw:bold c:white
		
	def render
		<self>
			<div.filter>
				<label for="card-ability">
					<span.span-ability> "Ability"
					<select#card-ability bind=selectedAbility @change=emit('filterBy', {prop:'ability', value:selectedAbility})>
						<option> ""
						for ability in abilities
							<option value=ability> ability
							
				<label for="card-energy"> 
					<span.span-energy> "Energy"
					<select#card-energy bind=selectedEnergy @change=emit('filterBy', {prop:'energy', value:selectedEnergy})>
						<option> ""
						for value in energyValues
							<option value=value> value
							
				<label for="card-power">
					<span.span-power> "Power"
					<select#card-power bind=selectedPower @change=emit('filterBy', {prop:'power', value:selectedPower})>
						<option> ""
						for value in powerValues
							<option value=value> value
								
				<label for="card-series">
					<span.span-series> "Series"
					<select#card-series bind=selectedSeries @change=emit('filterBy',  {prop:'series', value:selectedSeries})>
						<option> ""
						<option value="Season Pass"> "Season Pass"
						for num in [1...6]
							<option value="{num}"> `Series {num}`