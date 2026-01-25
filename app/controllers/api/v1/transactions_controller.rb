module Api
  module V1
    class TransactionsController < BaseController
      def index
        transactions = Transaction.where('customer_id = ? OR tasker_id = ?', current_user.id, current_user.id)
        transactions = apply_filters(transactions) if respond_to?(:apply_filters, true)
        transactions = apply_pagination(transactions)

        render json: transactions, status: :ok
      end

      private

      def resource_params
        params.require(:transaction).permit(
          :task_id, :amount, :platform_fee_percentage, :payment_method,
          :stripe_payment_intent_id
        )
      end

      def apply_filters(resources)
        resources = resources.where(status: params[:status]) if params[:status].present?
        resources = resources.where(payment_method: params[:payment_method]) if params[:payment_method].present?
        resources
      end
    end
  end
end
