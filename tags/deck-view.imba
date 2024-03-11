import blankCard from '../images/blank.webp'

tag deck-view
	prop cardsInDeck = []
	
	def removeCard card
		emit('removeCardFromDeck', card.name) if card

	css .deck-view p:5px 0 bgc:blue8 ta:center
		&.complete animation:complete .5s ease forwards
		img w:70px mx:-3px
			&.card-added@hover cursor:pointer scale:1.15
		@keyframes complete
			to bgc:red8/0 bg:url(../images/space.webp)
		
	def render
		<self>
			<div.deck-view .complete=(cardsInDeck.length is 12) [bgc:red8/90]=cardsInDeck.length>
				for num in [0...12]
					let link = ""
					let card = cardsInDeck[num]
					let altText = "blank card"

					if card
						link = card.image.replace('/', '/Marvel%20SNAP/Cards/')
						link = `https://res.cloudinary.com/dekvdfhbv/image/upload/{link}.webp`
						altText = card.name
					
					link = link or blankCard
					<img .card-added=card
						src=link
						alt=altText
						@click=removeCard(card)
					>