import { cards } from "./data/cards.imba"
import "./tags/cards-view.imba"
import "./tags/deck-view.imba"
import "./tags/filters.imba"
import "./tags/sorter.imba"
import "./tags/modal.imba"

const CARDS = cards.filter do(card) card.released and card.type is "character"

global css
	html, body m:0 ff:'Roboto', sans-serif
	body d:flex jc:center bgc:gray6
	button, select, input bd:none
	.deck-generator-controls d:flex gap:10px jc:center ai:center mt:12px
		input p:3px 8px bgc:azure c:#010b13
		input::placeholder c:#aaa9ad
		.controls-div d:flex gap:8px
		.btn-control all:unset d:flex
			svg filter:drop-shadow(2px 1px)
			@hover cursor:pointer
		.btn-control@hover, .btn-control@focus transform:scale(1.1)
	.toast-msg pos:fixed x:8px y:-18px bgc:#010b13 zi:1 p:5px 15px fw:bold fs:sm
	.sr-only bd:0 clip:rect(0 0 0 0) w:1px h:auto m:0 of:hidden p:0 pos:absolute white-space: nowrap

tag App
	prop cardsToDisplay = CARDS
	prop selectedKeyword = ""
	prop selectedAbility = ""
	prop selectedEnergy = ""
	prop selectedPower = ""
	prop selectedSeries = ""
	prop selectedSortProperty = "name"
	prop selectedSortOrder = "ascending"
	prop cardsInDeck = []
	prop showModal = false
	prop toastMsg = ""
			
	def filterCards
		let cardPool = []
		
		if !selectedAbility and !selectedKeyword
			cardPool = [...CARDS]
	
		if selectedKeyword
			for card in CARDS
				const cardName = card.name.toLowerCase()
				const keyword = selectedKeyword.toLowerCase()
				const ability =  card.ability and card.ability.toLowerCase()
				
				if ability
					if ability.includes(keyword)
					or cardName.includes(keyword)
						cardPool.push(card)
			
		if selectedAbility
			if selectedKeyword
				cardPool = cardPool.filter do(card) card.tags.includes(selectedAbility)
			else
				for card in CARDS
					cardPool.push(card) if card.tags.includes(selectedAbility)
		
		if selectedEnergy
			let foundCards = []
			for card in cardPool
				if selectedEnergy is '6+'
					foundCards.push(card) if card.cost >= 6	
				else
					foundCards.push(card) if card.cost is selectedEnergy
			cardPool = foundCards
					
		if selectedPower
			let foundCards = []
			for card in cardPool
				if selectedPower is '1-'
					foundCards.push(card) if card.power <= 1
				elif selectedPower is '6+'
					foundCards.push(card) if card.power >= 6	
				else
					foundCards.push(card) if card.power is selectedPower
			cardPool = foundCards
			
		if selectedSeries
			let foundCards = []
			for card in cardPool
				foundCards.push(card) if card.series is selectedSeries
			cardPool = foundCards

		sortCards(cardPool)
		cardsToDisplay = cardPool
		scrollToTop()
		
	def sortCards cards
		cards.sort do(a, b)
			if selectedSortProperty is 'name'
				if selectedSortOrder is 'descending'
					b.name.localeCompare(a.name)
				else
					a.name.localeCompare(b.name)
			else
				if selectedSortOrder is 'descending'
					b[selectedSortProperty] - a[selectedSortProperty]
				else
					a[selectedSortProperty] - b[selectedSortProperty]
					
	def sortCardsInDeck cards
		cards.sort do(a, b) a.cost - b.cost || a.power - b.power || a.name.localeCompare(b.name)
					
	def handleFilterChange event
		const prop = event.detail.prop
		let value = event.detail.value
		
		if prop is 'ability'
			selectedAbility = "" unless value
			selectedAbility = value.toLowerCase()
			filterCards()
		elif prop is 'energy'
			selectedEnergy = "" unless value
			selectedEnergy = value.toLowerCase()
			filterCards()
		elif prop is 'power'
			selectedPower = "" unless value
			selectedPower = value.toLowerCase()
			filterCards()
		elif prop is 'series'
			selectedSeries = "" unless value
			selectedSeries = value
			filterCards()

	def handleSortChange event
		const prop = event.detail.prop
		const value = event.detail.value.toLowerCase()
		
		if prop is 'field'
			selectedSortProperty = value
		else
			selectedSortOrder = value
		
		let cardsToSort = [...cardsToDisplay]					
		sortCards(cardsToSort)
		cardsToDisplay = cardsToSort
	
	def handleAddCardToDeck event
		const cardDetail = JSON.parse(event.detail)
		const cardName = cardDetail.name
		const isCardInDeck = cardsInDeck.find do(card) card.name is cardName
		
		if cardsInDeck.length < 12
			unless isCardInDeck
				cardsInDeck = sortCardsInDeck([...cardsInDeck, cardDetail])
			else
				handleRemoveCardFromDeck("", cardName)
		else
			if isCardInDeck
				handleRemoveCardFromDeck("", cardName)
			
	def handleRemoveCardFromDeck event, name
		const cardName = event.detail or name
		cardsInDeck = cardsInDeck.filter do(card) card.name isnt cardName
	
	def copyDeckCode
		if cardsInDeck.length
			const deck = { Cards: [] }
			let deckStr = ""
			cardsInDeck.forEach do(card)
				let id = card.code or card.name.replace(/[^\w^_]/g, '')
				deck.Cards.push { CardDefId: id }
				deckStr += ("# ({card.cost}) {card.name}\n")
						
			let deckCode = window.btoa(JSON.stringify(deck))
			deckCode = "{deckStr}#\n{deckCode}\n#\n# To use this deck, copy it to your clipboard and paste it from the deck editing menu in Snap."
			const textarea = document.createElement('textarea')
			textarea.value = deckCode
			document.body.appendChild(textarea)
			textarea.select()
			document.execCommand('copy')
			document.body.removeChild(textarea)
			
			toastMsg = {color:'green5', msg:"Deck code copied to the clipboard!"}
			setTimeout(&,1000) do
				toastMsg = ""
				imba.commit()
		else
			toastMsg = {color:'yellow5', msg:"The deck is empty!"}
			setTimeout(&,1000) do
				toastMsg = ""
				imba.commit()
				
	def importDeckCode event
		showModal = false
		
		try
			let code = event.detail.trim()
			return unless code
			code = code.match(/\n[\w=\+\/^_]+\n/) or code
			const decodedDeckCode = window.atob(code)
			let cards = JSON.parse(decodedDeckCode).Cards
			cards = cards.map do(card) card.CardDefId.toLowerCase()
			
			let foundCards = []
			for cardName in cards
				for card in CARDS
					const name = card.name.toLowerCase().replace(/[^\w^_]/g, '')
					foundCards.push(card) if name is cardName or card.code is cardName
			cardsInDeck = foundCards
		catch
			toastMsg = {color:'red5', msg:"Invalid deck code!"}
			setTimeout(&,1000) do
				toastMsg = ""
				imba.commit()
		
	def toggleModal event
		if event.detail
			showModal = false if event.detail.classes.includes('deck-builder-modal')
		else
			showModal = true
			
	def scrollToTop
		const cardsDiv = document.querySelector('.cardsDiv')
		cardsDiv.scrollTo({top:0, behavior:"smooth"})
	
	def resetDeckBuilder
		cardsToDisplay = CARDS
		selectedKeyword = ""
		selectedAbility = ""
		selectedEnergy = ""
		selectedPower = ""
		selectedSeries = ""
		selectedSortProperty = "name"
		selectedSortOrder = "ascending"
		cardsInDeck = []
		showModal = false
		toastMsg = ""
		scrollToTop()
	
	def render
		<self @toggleModal=toggleModal>
			css w:420px h:600px bgc:blue9
			
			<deck-view
				cardsInDeck=cardsInDeck
				@removeCardFromDeck=handleRemoveCardFromDeck
			>
			
			if toastMsg
				<div.toast-msg [c:{toastMsg.color} shadow: -3px 0 {toastMsg.color}]> toastMsg.msg
			
			<cards-view.cardsDiv
				cardsInDeck=cardsInDeck
				cardsToDisplay=cardsToDisplay
				@addCardToDeck=handleAddCardToDeck
			>
					
			<div.deck-generator>
				<filters
					selectedAbility=selectedAbility
					selectedEnergy=selectedEnergy
					selectedPower=selectedPower
					selectedSeries=selectedSeries
					@filterBy=handleFilterChange
				>
				<sorter
					selectedSortProperty=selectedSortProperty
					selectedSortOrder=selectedSortOrder
					@sortBy=handleSortChange
				>
				<div.deck-generator-controls>
					<label.sr-only for="keyword-searcher"> "Search By Keyword"
					<input#keyword-searcher
						type="text"
						placeholder="keyword"
						bind=selectedKeyword
						@input.throttle=filterCards
					>
					<div.controls-div>
						<button.btn-control @click.throttle(1000)=copyDeckCode aria-label="Copy Deck Code" title="Copy Deck Code">
							<svg src='./images/save.svg'>
						
						<button.btn-control @click=emit('toggleModal') aria-label="Import Deck Code" title="Import Deck Code">
							<svg src='./images/import.svg'>
						
						<button.btn-control @click=resetDeckBuilder aria-label="Reset All" title="Reset All">
							<svg src='./images/reset.svg'>
			
			if showModal
				<deck-builder-modal
					@deckCodeImported=importDeckCode
					@toggleModal=toggleModal
				>


imba.mount <App>