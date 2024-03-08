tag cards-view
	prop cardsToDisplay = []
	prop cardsInDeck = []
	prop cardInfo = ""
	
	def isCardInDeck name
		cardsInDeck.filter do(card) card.name is name
	
	css h:320px of:auto bgc:midnightblue p:5px 0 bdt:2px solid gray9 bdb:2px solid gray9
		scrollbar-width:thin scrollbar-color:#C82922 #708090
		.no-cards ta:center c:gray4 fw:bold
		img w:100px
			@hover cursor:pointer scale:1.18
			&.selected opacity:0.3
		.card-info pos:fixed x:10px y:280px zi:1 w:250px fs:xs bgc:#010b13 rd:sm
			p:8px c:lightcyan fw:bold
			h3, h4, p p:0 m:0
			h3 c:#ffd700 fs:md
			h4 c:#00a8ff fs:sm
			span c:red5
	
	def render
		<self>
			<div.all-cards>
				unless cardsToDisplay.length
					<p.no-cards>
						<em> "No cards found."
				if (cardInfo)
					<div.card-info>
						<p>
							<h3> cardInfo.name
							<h4> "Cost: {cardInfo.cost}"
								<span> " ┇ " 
								"Power: {cardInfo.power}"
							
							if cardInfo.ability
								<p> cardInfo.ability.replace('<i>','').replace('</i>','')
							else
								<p> <i> cardInfo.text
								<br>
								<p> "Evolved: {cardInfo.evolved.replace('<i>','').replace('</i>','')}"
				
				for card in cardsToDisplay
					let link = card.image.replace('/', '/Marvel%20SNAP/Cards/') + '.webp'
					link = 'https://res.cloudinary.com/dekvdfhbv/image/upload/' + link
					<img.card-image .selected=isCardInDeck(card.name).length
						src=link
						alt=card.name
						@click=emit('addCardToDeck', `{JSON.stringify(card)}`)
						@mouseover=(cardInfo=card)
						@mouseout=(cardInfo="")
					>