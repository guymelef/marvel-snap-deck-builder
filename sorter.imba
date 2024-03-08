tag sorter
	prop selectedSortProperty
	prop selectedSortOrder
	
	css .sorter fs:sm d:flex jc:center ai:center gap:5px mt:8px
		select width:100px
		span fw:bold mr:5px c:lightcyan
		select bgc:steelblue c:#010b13
		option fw:bold c:white
		
	def render
		<self>
			<div.sorter>				
				<label for="sort-category">
					<span> "Sort Property"
					<select#sort-category bind=selectedSortProperty @change=emit('sortBy', {prop:'field', value:selectedSortProperty})>
						<option value="name" selected> "Name"
						<option value="cost"> "Energy"
						<option value="power"> "Power"
						
				<label for="sort-order">
					<span> "Sort Order"
					<select#sort-order bind=selectedSortOrder @change=emit('sortBy', {prop:'order', value:selectedSortOrder})>
						<option value="ascending" selected> "Ascending"
						<option value="descending"> "Descending"