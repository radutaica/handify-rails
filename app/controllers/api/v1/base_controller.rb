module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_user!
      before_action :set_resource, only: [:show, :update, :destroy]

      # GET /api/v1/resources
      def index
        resources = resource_class.all
        resources = apply_filters(resources) if respond_to?(:apply_filters, true)
        resources = apply_pagination(resources)

        render json: resources, status: :ok
      end

      # GET /api/v1/resources/:id
      def show
        render json: @resource, status: :ok
      end

      # POST /api/v1/resources
      def create
        resource = resource_class.new(resource_params)

        if resource.save
          render json: resource, status: :created
        else
          render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/resources/:id
      def update
        if @resource.update(resource_params)
          render json: @resource, status: :ok
        else
          render json: { errors: @resource.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/resources/:id
      def destroy
        if @resource.destroy
          head :no_content
        else
          render json: { errors: @resource.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_resource
        @resource = resource_class.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "#{resource_class.name} not found" }, status: :not_found
      end

      def resource_class
        @resource_class ||= controller_name.classify.constantize
      end

      def resource_params
        # Override this method in child controllers
        params.require(controller_name.singularize.to_sym).permit!
      end

      def apply_pagination(resources)
        page = params[:page] || 1
        per_page = params[:per_page] || 25
        per_page = [per_page.to_i, 100].min # Max 100 per page

        resources.offset((page.to_i - 1) * per_page).limit(per_page)
      end
    end
  end
end
