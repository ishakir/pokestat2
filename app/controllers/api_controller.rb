require 'date'

class ApiController < ApplicationController
	# generation, tier, usage_pct
	def metadata
		# TODO: Replace me with group_by
		results = Source.select(:generation, :tier, :min_rank).distinct
		response = results
			.group_by { |res| res.generation }
			.map do |gen, results2| 
				[
					gen, 
					results2
						.group_by { |res2| res2.tier }
						.map do |tier, results3| 
							[
								tier, 
								results3.map { |res3| 
									res3.min_rank 
								}
							] 
						end.to_h
				]
			end.to_h

		render json: response
	end

	def pokemon
		generation = params[:generation].to_i
		tier = params[:tier]
		min_rank = params[:min_rank].to_i

		render json: 
			Usage
			.joins(:source)
			.select(:pokemon)
			.where(
				sources: {
					generation: generation, 
					tier: tier, 
					min_rank: min_rank
				}
			)
			.distinct
			.order(:pokemon)
			.map { |res| 
				res.pokemon
			}
	end

	def usage
		generation = params[:generation].to_i
		tier = params[:tier]
		min_rank = params[:min_rank]
		pokemon = params[:pokemon].split(",")

		results = Usage
				.joins(:source)
				.select(:pokemon, :year, :month, :usage_pct)
				.where(
					sources: {
						generation: generation, 
						tier: tier, 
						min_rank: min_rank
					},
					usages: {
						:pokemon => pokemon
					}
				)

		dates = SortedSet.new
		pokemon = {}

		results.each do |result|
			year_month = Date.new(result.year, result.month, 1).strftime("%Y-%m")
			dates.add(year_month)
			if not pokemon.include?(result.pokemon)
				pokemon[result.pokemon] = {}
			end
			pokemon[result.pokemon][year_month] = result.usage_pct
		end

		response = {
			dates: dates.to_a,
			data: {}
		}

		pokemon.each do |pokemon2, data|
			response[:data][pokemon2] = dates.map { |date| if(data.include?(date)) then data[date] else 0 end }
		end

		render json: response
			
	end

end
