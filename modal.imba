tag deck-builder-modal
	prop deckCode
	
	def importDeck
		emit('deckCodeImported', deckCode)
		deckCode = ""
		
	css .deck-builder-modal w:100% h:100% bgc:blue9/95 of:auto 
		pos:fixed top:0 left:0 zi:1 animation:fade-in .3s
		.deck-builder-modal-content bgc:#151E3F w:300px h:260px ta:center p:3px 15px 
			m:auto 	rd:md pos:relative animation:slide-in .3s forwards d:vflex ai:center
		label fw:bold c:lightcyan fs:xl text-transform:uppercase
		textarea w:100% c:#080808 resize:none p:5px bgc:#CBCBD4
		textarea::placeholder c:gray fs:sm
		span pos:absolute t:-22px c:gray4 fs:sm font-style:italic fw:bold
		button p:5px 15px bgc:#FF9B42 c:lightcyan fw:bold rd:20px mt:10px
			@hover cursor:pointer bgc:warm2 c:orange5
		@keyframes slide-in
			from t:-300px o:0
			to t:150px o:1
		@keyframes fade-in
			from o:0
			to o:1
	
	def render
		<self>
			<div.deck-builder-modal @click=emit('toggleModal', {classes:[...e.target.classList]})>
				<div.deck-builder-modal-content>
					<span> "■ Click on a blank area to close ■"
					<label for="deck-code"> "Import Deck Code"
					<textarea#deck-code
						placeholder="Paste your deck code here..."
						rows=9
						bind=deckCode
					>
					<button @click=importDeck> "Submit"